# Create a public IP for the Application Gateway (aka WAF "Web Application Firewall")
module "public_ip" {
  source              = "../../modules/public_ip/"
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.pip_name
  domain_name_label   = var.pip_domain_name_label
  ip_version          = var.pip_ip_version
  sku                 = var.pip_sku
}

# Create a subnet for the Application Gateway
resource "azurerm_subnet" "subnet_waf" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.vnet_address_space
}

# Create an Application Gateway
resource "azurerm_application_gateway" "application_gateway" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  firewall_policy_id  = azurerm_web_application_firewall_policy.web_application_firewall_policy.id

  sku {
    name = var.sku_name
    tier = var.sku_tier
  }

  autoscale_configuration {
    min_capacity = 0
    max_capacity = 2
  }

  gateway_ip_configuration {
    name      = "${var.name}-ipconfig"
    subnet_id = "${var.vnet_id}/subnets/${azurerm_subnet.subnet_waf.name}"
  }

  # HTTPS port used for customer traffic
  # frontend_port {
  #   name = "${var.name}-feport-443"
  #   port = 443
  # }

  # HTTPS port used for customer traffic
  frontend_port {
    name = "${var.name}-feport-80"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "${var.name}-feip"
    public_ip_address_id = module.public_ip.id
  }

  backend_address_pool {
    name         = "${var.name}-beap"
    ip_addresses = split(",", var.ip_addresses)
  }

  backend_http_settings {
    name                  = "${var.name}-behttp"
    cookie_based_affinity = "Disabled"
    port                  = var.backend_port
    protocol              = "Http"
    request_timeout       = var.backend_request_timeout
  }

  http_listener {
    name                           = "${var.name}-httplstn"
    frontend_ip_configuration_name = "${var.name}-feip"
    frontend_port_name             = "${var.name}-feport-80"
    protocol                       = "Http"
    firewall_policy_id             = azurerm_web_application_firewall_policy.web_application_firewall_policy.id
  }

  # Routing rule used to redirect customer traffic to the backend  
  request_routing_rule {
    name                       = "${var.name}-rqrt"
    rule_type                  = "Basic"
    http_listener_name         = "${var.name}-httplstn"
    backend_address_pool_name  = "${var.name}-beap"
    backend_http_settings_name = "${var.name}-behttp"
  }

  probe {
    name                                      = var.health_probe_name
    protocol                                  = var.health_probe_protocol
    path                                      = var.health_probe_path
    pick_host_name_from_backend_http_settings = var.pick_host_name_from_backend_http_settings
    interval                                  = 5
    timeout                                   = 30
    unhealthy_threshold                       = 3
  }
}

resource "azurerm_web_application_firewall_policy" "web_application_firewall_policy" {
  name                = var.policy_name
  resource_group_name = var.resource_group_name
  location            = var.location

  custom_rules {
    name      = "${var.name}-rule-1"
    priority  = 1
    rule_type = "MatchRule"

    match_conditions {
      match_variables {
        variable_name = "RemoteAddr"
      }

      operator           = "GeoMatch"
      negation_condition = true
      match_values       = ["US"]
    }

    action = "Block"
  }

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.0"
      rule_group_override {
        rule_group_name = "REQUEST-931-APPLICATION-ATTACK-RFI"
        disabled_rules  = [931130]
      }
    }
  }

}