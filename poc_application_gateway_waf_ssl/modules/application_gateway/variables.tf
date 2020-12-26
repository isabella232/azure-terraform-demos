variable "name" {
  description = "Name of the WAF"
}

variable "resource_group_name" {
  description = "Name of the parent resource group"
}

variable "location" {
  description = "Location of the WAF"
}

variable "subnet_name" {
  description = "The name of the subnet. Changing this forces a new resource to be created"
}

variable "pip_name" {
  description = "Name for the Public IP of the WAF"
}

variable "pip_domain_name_label" {
  description = "Domain name label of the WAF"
}

variable "pip_ip_version" {
  description = "IP version of the Public IP"
}

variable "vnet_id" {
  description = "Name of the vnet the waf will be placed in"
}

variable "vnet_name" {
  description = "Name of the vnet the waf will be placed in"
}

variable "vnet_address_space" {
  description = "Network address of the vnet in CIDR notation"
  type        = list(string)
}

variable "backend_port" {
  description = "The port the WAF will user for traffic forwarding"
}

variable "sku_name" {
  description = "WAF SKU name e.g. 'WAF_Medium'"
  default     = "WAF_Medium"
}

variable "sku_tier" {
  description = "Tier of WAF, possible values: 'Standard, WAF'"
  default     = "WAF"
}

variable "capacity" {
  description = "Number of WAF nodes"
  default     = 1
}

variable "ip_addresses" {
  description = "A list of IP Addresses which should be part of the Backend Address Pool"
}

variable "backend_request_timeout" {
  description = "The request timeout in seconds, which must be between 1 and 86400 seconds"
}

variable "frontend_tls_certificate" {
  description = "Base64-encoded PFX file with frontend TLS certificate"
}

variable "health_probe_name" {
  description = "The Name of the Probe."
  default     = "probe"
}

variable "health_probe_path" {
  description = "The Path used for this Probe"
  default     = "/"
}

variable "health_probe_protocol" {
  description = "The Protocol used for this Probe. Possible values are Http and Https"
  default     = "Http"
}

variable "pick_host_name_from_backend_http_settings" {
  description = "Whether the host header should be picked from the backend http settings. Defaults to false."
  default     = true
}
 