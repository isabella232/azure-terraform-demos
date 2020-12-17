variable "project_name" {
  description = "Name of the project"
}

variable "stage" {
  description = "Name of the stage"
}

variable "region" {
  description = "Name of the region"
}

variable "location" {
  description = "Location of the deployment"
}

variable "vnet_01_address_space" {
  description = "Virtual network address space for 01"
}

variable "vm_01_subnet_address_prefix" {
  description = "Subnet address prefix for vm"
}

variable "waf_01_subnet_address_prefix" {
  description = "Subnet address prefix for the Application Gateway"
}


