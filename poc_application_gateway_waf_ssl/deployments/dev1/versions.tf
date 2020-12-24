
terraform {
  required_providers {
    # https://github.com/terraform-providers/terraform-provider-azurerm/blob/master/CHANGELOG.md
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.40.0"
    }
  }
}