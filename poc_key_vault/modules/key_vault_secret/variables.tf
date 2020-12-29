variable "name" {
  description = "Specifies the name of the Key Vault Secret. Changing this forces a new resource to be created."
}

variable "secret" {
  description = "Specifies the value of the Key Vault Secret."
}

variable "key_vault_id" {
  description = "The ID of the Key Vault where the Secret should be created."
}