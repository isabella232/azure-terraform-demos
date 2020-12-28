resource "azurerm_frontdoor" "frontdoor" {
  name                                         = var.name
  resource_group_name                          = var.resource_group_name
  enforce_backend_pools_certificate_name_check = false

  backend_pool {
    name                = "${var.name}-backend-pool"
    health_probe_name   = "${var.name}-backend-pool-health-probe"
    load_balancing_name = "${var.name}-backend-pool-load-balancing"

    backend {
      host_header = var.backend_pool_host_header
      address     = var.backend_pool_address
      http_port   = 80
      https_port  = 443
    }
  }

  backend_pool_health_probe {
    name = "${var.name}-backend-pool-health-probe"
  }

  backend_pool_load_balancing {
    name = "${var.name}-backend-pool-load-balancing"
  }

  frontend_endpoint {
    name                                    = "${var.name}-frontend-endpoint"
    host_name                               = "${var.name}.azurefd.net"
    custom_https_provisioning_enabled       = false
    web_application_firewall_policy_link_id = var.frontend_endpoint_web_application_firewall_policy_link_id
  }

  routing_rule {
    name               = "${var.name}-routing-rule"
    frontend_endpoints = ["${var.name}-frontend-endpoint"]
    patterns_to_match  = ["/*"]
    accepted_protocols = ["Http", "Https"]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "${var.name}-backend-pool"
    }
  }
}