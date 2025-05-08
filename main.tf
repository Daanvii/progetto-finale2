provider "azurerm" {
    features {}
    subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "nuovo_gruppo_risorse2" {
  name     = var.resource_group_name
  location = "West Europe"
}

resource "azurerm_virtual_network" "nuova_vnet2" {
  name                = "nuova-vnet2"
  resource_group_name = azurerm_resource_group.nuovo_gruppo_risorse2.name
  location            = azurerm_resource_group.nuovo_gruppo_risorse2.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "nuova_subnet2" {
  name                 = "nuova-subnet2"
  resource_group_name  = azurerm_resource_group.nuovo_gruppo_risorse2.name
  virtual_network_name = azurerm_virtual_network.nuova_vnet2.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nuova_nsg2" {
  name                = "nuova-nsg2"
  resource_group_name = azurerm_resource_group.nuovo_gruppo_risorse2.name
  location            = "West Europe"

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowK3sNodePort"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "30080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc2" { # Questo comando associa un Network Security Group (NSG) a una subnet
  subnet_id                 = azurerm_subnet.nuova_subnet2.id
  network_security_group_id = azurerm_network_security_group.nuova_nsg2.id
}

resource "azurerm_public_ip" "nuova_public_ip2" { # Definisce un indirizzo IP pubblico in Azure, necessario per rendere accessibile la VM dall'esterno
  name                = "nuova-public-ip2"
  resource_group_name = azurerm_resource_group.nuovo_gruppo_risorse2.name
  location            = azurerm_resource_group.nuovo_gruppo_risorse2.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nuova_nic2" {  # Scheda di Interfaccia di Rete, permette alla VM di comunicare con altre risorse, Internet o con reti interne.
  name                = "nuova-nic2"
  location            = azurerm_resource_group.nuovo_gruppo_risorse2.location
  resource_group_name = azurerm_resource_group.nuovo_gruppo_risorse2.name

  ip_configuration { # Permette alla VM di avere sia un IP privato (nella subnet interna) che un IP pubblico (per accesso esterno).
    name                          = "internal"
    subnet_id                     = azurerm_subnet.nuova_subnet2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.nuova_public_ip2.id
  }
}

resource "azurerm_linux_virtual_machine" "nuova_vm2" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.nuovo_gruppo_risorse2.name
  location            = "West Europe"
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.nuova_nic2.id] # Permette alla macchina di connettersi alla rete
  disable_password_authentication = false 

  os_disk {  # configura il disco principale della VM.
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {  # 
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  #  Provisioner per copiare setup.sh sulla VM
  provisioner "file" {
    source      = "setup.sh"
    destination = "/tmp/setup.sh"

    connection {
      type     = "ssh"
      user     = var.admin_username
      password = var.admin_password
      host     = azurerm_public_ip.nuova_public_ip2.ip_address
    }
  }

  # 🔹 Provisioner per eseguire setup.sh sulla VM
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "/tmp/setup.sh"
    ]

    connection {
      type     = "ssh"
      user     = var.admin_username
      password = var.admin_password
      host     = azurerm_public_ip.nuova_public_ip2.ip_address
    }
  }
}
