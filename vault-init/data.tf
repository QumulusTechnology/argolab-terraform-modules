data "azurerm_key_vault" "global" {
  name                = var.keyvault_name_global
  resource_group_name = "global"
}

data "azurerm_key_vault" "argo" {
  name                = var.keyvault_name_argo
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_secret" "global-vault-token" {
  count = local.is_prod_or_dev == true ? 0 : 1
  name         = "vault-token"
  key_vault_id = data.azurerm_key_vault.global.id
}

data "kubernetes_secret" "database_password" {
  metadata {
    name = "postgres-auth"
    namespace = "database"
  }
}

data "vault_identity_group" "vault_admins" {
  group_name = "Vault Admins"
  depends_on = [
    module.vault_azure_ad_groups
  ]
}

data "vault_identity_group" "engineering" {
  group_name = "Engineering"
  depends_on = [
    module.vault_azure_ad_groups
  ]
}

data "vault_identity_group" "devops" {
  group_name = "DevOps"
  depends_on = [
    module.vault_azure_ad_groups
  ]
}
