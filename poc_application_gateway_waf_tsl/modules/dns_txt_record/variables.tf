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

variable "record" {
  description = "A list of values that make up the txt record. Each record block supports fields documented below."
}
