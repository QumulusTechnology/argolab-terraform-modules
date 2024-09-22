# resource "azurerm_key_vault_secret" "vault_token" {
#   name         = "vault-token"
#   value        = var.vault_token
#   key_vault_id = data.azurerm_key_vault.argo.id
# }

# resource "azurerm_key_vault_secret" "vault_init_response" {
#   name         = "vault-init-response"
#   value        = var.vault_init_response
#   key_vault_id = data.azurerm_key_vault.argo.id
# }
