resource "azurerm_key_vault_secret" "secret" {
  name         = var.name
  value        = var.secret
  key_vault_id = var.key_vault_id
}

