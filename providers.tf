provider "vault" {
  #address = "https://${var.parent_domain}"
  #token   = data.azurerm_key_vault_secret.global-vault-token[*].value
  address         = "https://vault.${local.domain}"
  token           = local.vault_token
  alias           = "parent"
  skip_tls_verify = data.external.wait_for_vault.result.skip_tls_verify
  skip_child_token = true
}

provider "vault" {
  address          = "https://vault.${local.domain}"
  token            = local.vault_token
  skip_tls_verify  = data.external.wait_for_vault.result.skip_tls_verify
  skip_child_token = true
}
