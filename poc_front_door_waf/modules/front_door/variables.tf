variable "name" {
  description = "Specifies the name of the Front Door service. Must be globally unique. Changing this forces a new resource to be created."
}

variable "resource_group_name" {
  description = "Specifies the name of the Resource Group in which the Front Door service should exist. Changing this forces a new resource to be created."
}

variable "backend_pool_host_header" {
  description = "The value to use as the host header sent to the backend."
}

variable "backend_pool_address" {
  description = "Location of the backend (IP address or FQDN)"
}

variable "frontend_endpoint_web_application_firewall_policy_link_id" {
  description = "Defines the Web Application Firewall policy ID for each host."
}