# Create a public IP for the Application Gateway (aka WAF "Web Application Firewall")
module "public_ip" {
  source              = "../../modules/public_ip/"
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.pip_name
  domain_name_label   = var.pip_domain_name_label
  ip_version          = var.pip_ip_version
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

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.capacity
  }

  gateway_ip_configuration {
    name      = "${var.name}-ipconfig"
    subnet_id = "${var.vnet_id}/subnets/${azurerm_subnet.subnet_waf.name}"
  }

  # HTTPS port used for customer traffic
  frontend_port {
    name = "${var.name}-feport"
    port = 443
  }

  # HTTP port used to redirect traffic from HTTP to HTTPS
  frontend_port {
    name = "${var.name}-feport-redir"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "${var.name}-feip"
    public_ip_address_id = module.public_ip.id
  }

  ssl_certificate {
    name = "frontend-cert"
    data = var.frontend_tls_certificate
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
    frontend_port_name             = "${var.name}-feport"
    protocol                       = "Https"
    ssl_certificate_name           = "frontend-cert"
  }

  # HTTP listener used to redirect traffic from HTTP to HTTPS
  http_listener {
    name                           = "${var.name}-httplstn-redir"
    frontend_ip_configuration_name = "${var.name}-feip"
    frontend_port_name             = "${var.name}-feport-redir"
    protocol                       = "Http"
  }

  # Redirect configuration used to redirect traffic from HTTP to HTTPS
  redirect_configuration {
    name                 = "${var.name}-http-2-https-redir"
    redirect_type        = "Permanent"
    target_listener_name = "${var.name}-httplstn"
    include_path         = "true"
    include_query_string = "true"
  }

  # Routing rule used to redirect traffic from HTTP to HTTPS
  request_routing_rule {
    name                        = "${var.name}-rqrt-redir"
    rule_type                   = "Basic"
    http_listener_name          = "${var.name}-httplstn-redir"
    redirect_configuration_name = "${var.name}-http-2-https-redir"
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

  ssl_policy {
    policy_name = "AppGwSslPolicy20170401S" # Pre-defined policy for increased security whose minimum protocol version accepted is TLSv1.2
    policy_type = "Predefined"              # The Type of the Policy.
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.0"

    disabled_rule_group {
      # Disable rule 931130
      # Possible Remote File Inclusion (RFI) Attack: Off-Domain Reference/Link
      rule_group_name = "REQUEST-931-APPLICATION-ATTACK-RFI"
      rules           = [931130]
    }
  }
}
