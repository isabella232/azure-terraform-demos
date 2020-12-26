# https://github.com/hashicorp/terraform/releases
terraform {
  required_version = "~> 0.14.2"
}

provider "azurerm" {
  features {
  }
}

resource "azurerm_web_application_firewall_policy" "web_application_firewall_policy" {
  # (resource arguments)
}
