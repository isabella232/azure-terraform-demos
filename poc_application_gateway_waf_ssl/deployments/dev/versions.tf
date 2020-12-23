
terraform {
  required_providers {
    # https://github.com/terraform-providers/terraform-provider-azurerm/blob/master/CHANGELOG.md
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.40.0"
    }
    # https://github.com/vancluever/terraform-provider-acme/blob/master/CHANGELOG.md
    acme = {
      source  = "vancluever/acme"
      version = "1.6.3"
    }
  }
}