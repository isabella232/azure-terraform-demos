variable "name" {
  description = "Name of the Key Vault"
}

variable "resource_group_name" {
  description = "Name of the parent resource group"
}

variable "location" {
  description = "Location of the Key Vault"
}

variable "enabled_for_disk_encryption" {
  description = "Specify whether the KV supports disk encryption"
  default     = true
}

variable "tenant_id" {
  description = "Tenant ID"
}

variable "sp_object_id" {
  description = "Object ID of the pipeline service principal"
}

variable "owner_object_id" {
  description = "Object ID of subscription owner"
}