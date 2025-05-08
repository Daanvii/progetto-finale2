output "vm_public_ip" {
  description = "Indirizzo IP pubblico della VM"
  value       = azurerm_public_ip.nuova_public_ip2.ip_address
}

output "vm_private_ip" {
  description = "Indirizzo IP privato della VM"
  value       = azurerm_network_interface.nuova_nic2.private_ip_address
}
