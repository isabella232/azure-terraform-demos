# https://github.com/hashicorp/terraform/releases
terraform {
  required_version = "~> 0.14.2"
}

provider "azurerm" {
  features {
  }
}

# Create a resource group for the platform runtime
module "resource_group_01" {
  source   = "../../modules/resource_group/"
  name     = "${var.project_name}-rg-${var.region}-${var.stage}"
  location = var.location
}

# Create an app service plan
module "app_service_plan_01" {
  source              = "../../modules/app_service_plan/"
  name                = "${var.project_name}-appsrvplan-${var.region}-${var.stage}"
  location            = var.location
  resource_group_name = module.resource_group_01.name
  kind                = "Linux"
  reserved            = true
  sku_tier            = "Basic"
  sku_size            = "B1"
}

# Create an app service
module "app_service_01" {
  source              = "../../modules/app_service/"
  name                = "${var.project_name}-appsrv-${var.region}-${var.stage}"
  location            = var.location
  resource_group_name = module.resource_group_01.name
  app_service_plan_id = module.app_service_plan_01.id
  linux_fx_version    = "DOCKER|httpd:latest"
}

# Create a front door endpoint
module "front_door" {
  source                                                    = "../../modules/front_door/"
  name                                                      = "${var.project_name}-frontdoor-${var.region}-${var.stage}"
  resource_group_name                                       = module.resource_group_01.name
  backend_pool_host_header                                  = module.app_service_01.default_site_hostname
  backend_pool_address                                      = module.app_service_01.default_site_hostname
  frontend_endpoint_web_application_firewall_policy_link_id = module.front_door_web_application_firewall_policy.id
}

# Create a WAF policy
module "front_door_web_application_firewall_policy" {
  source              = "../../modules/front_door_web_application_firewall_policy/"
  name                = "wafpolicy"
  resource_group_name = module.resource_group_01.name
}