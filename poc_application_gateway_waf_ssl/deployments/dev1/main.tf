# https://github.com/hashicorp/terraform/releases
terraform {
  required_version = "~> 0.14.2"
}

provider "azurerm" {
  features {
  }
}

# Create a resource group
module "resource_group_01" {
  source   = "../../modules/resource_group/"
  name     = "${var.project_name}-rg-${var.region}-${var.stage}"
  location = var.location
}

# Create a DNS zone
resource "azurerm_dns_zone" "dns_zone" {
  name                = var.domain_url
  resource_group_name = module.resource_group_01.name
}

# Create a TXT record
module "dns_txt_record_core" {
  source              = "../../modules/dns_txt_record/"
  name                = "@"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = module.resource_group_01.name
  ttl                 = 0
  record              = "check_domain_ok"
}
