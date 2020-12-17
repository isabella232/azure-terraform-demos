variable "name" {
  description = "The name of the Network Interface. Changing this forces a new resource to be created."
}

variable "location" {
  description = "Location of the resource group"
}

variable "resource_group_name" {
  description = "Name of the parent resource group"
}

variable "ip_configuration_name" {
  description = "A name used for this IP Configuration"
}

variable "ip_configuration_subnet_id" {
  description = "The ID of the Subnet where this Network Interface should be located in"
}

variable "ip_configuration_private_ip_address_allocation" {
  description = "The allocation method used for the Private IP Address. Possible values are Dynamic and Static"
}