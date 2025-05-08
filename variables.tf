variable "subscription_id" {
  description = "ID della sottoscrizione Azure"
  type        = string
}

variable "resource_group_name" {
  description = "Nome del gruppo di risorse"
  type        = string
}

variable "vm_name" {
  description = "Nome della VM"
  type        = string
}

variable "admin_username" {
  description = "Username per la VM"
  type        = string
}

variable "admin_password" {
  description = "Password per la VM"
  type        = string
  sensitive   = true   #  Protegge la password nei log Terraform!
}