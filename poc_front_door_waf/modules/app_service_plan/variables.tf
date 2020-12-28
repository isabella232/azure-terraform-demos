variable "name" {
  description = " Specifies the name of the App Service Plan component. Changing this forces a new resource to be created."
}

variable "resource_group_name" {
  description = "Name of the parent resource group"
}

variable "location" {
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}


variable "kind" {
  description = "The Operating System type of the App Service Plan"
}

variable "reserved" {
  description = " Is this App Service Plan Reserved"
}


variable "sku_tier" {
  description = "Specifies the plan's pricing tier."
}

variable "sku_size" {
  description = "Specifies the plan's instance size."
}
