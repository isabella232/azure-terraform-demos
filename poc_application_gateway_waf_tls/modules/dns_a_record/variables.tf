variable "name" {
  description = "The name of the DNS A Record"
}

variable "resource_group_name" {
  description = "Specifies the resource group where the resource exists"
}

variable "zone_name" {
  description = "Specifies the DNS Zone where the resource exists"
}

variable "ttl" {
  description = "The Time To Live (TTL) of the DNS record in seconds"
}

variable "records" {
  type        = list(any)
  description = "List of IPv4 Addresses"
}
