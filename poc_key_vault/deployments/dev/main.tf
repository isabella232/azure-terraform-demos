# https://github.com/hashicorp/terraform/releases
terraform {
  required_version = "~> 0.14.2"
}

provider "azurerm" {
  features {
  }
}

# Read data from the Pipeline Service Principal for later use in the Key Vault module and Key Vault Access Policy (Object ID)
data "azuread_service_principal" "pipeline_service_principal" {
  display_name = "poc-terraform"
}
data "azurerm_client_config" "current" {}

# Create a resource group for the platform runtime
module "resource_group_01" {
  source   = "../../modules/resource_group/"
  name     = "${var.project_name}-rg-${var.region}-${var.stage}"
  location = var.location
}

module "key_vault" {
  source              = "../../modules/key_vault/"
  name                = "${var.project_name}-kv01-${var.region}-${var.stage}"
  resource_group_name = module.resource_group_01.name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  # Parameters to create an Access Policy for the Pipeline Service Principal
  sp_object_id = data.azuread_service_principal.pipeline_service_principal.object_id

  # Parameters to create an Access Policy for subscription Owner
  owner_object_id = "xxxx"
}

# Generate random passwords
resource "random_password" "random_password_32" {
  length           = 32
  special          = true
  override_special = "+-=*/"
}

module "key_vault_secret" {
  source = "../../modules/key_vault_secret/"

  key_vault_id = module.key_vault.id
  name         = "${var.project_name}-secret-${var.region}-${var.stage}-random-string"
  secret       = random_password.random_password_32.result
}