data "terraform_remote_state" "argolab" {
  backend = "azurerm"
  config = {
    resource_group_name  = "global"
    storage_account_name = var.storage_account_name
    container_name       = "tfstate"
    key                  = "${var.branch_clean}/argolab"
    subscription_id      = var.subscription_id
    tenant_id            = var.tenant_id
  }
}

data "azurerm_key_vault" "global" {
  name                = data.terraform_remote_state.argolab.outputs.keyvault_name_global
  resource_group_name = "global"
}

data "azurerm_key_vault" "argo" {
  name                = data.terraform_remote_state.argolab.outputs.keyvault_name_argo
  resource_group_name = data.terraform_remote_state.argolab.outputs.resource_group_name
}

data "azurerm_key_vault_secret" "global-vault-token" {
  count = local.is_prod_or_dev == true ? 0 : 1
  name         = "vault-token"
  key_vault_id = data.azurerm_key_vault.global.id
}

data "azurerm_key_vault_secret" "vault-token" {
  name         = "vault-token"
  key_vault_id = data.azurerm_key_vault.argo.id
}

data "azurerm_key_vault_secret" "vault-init-response" {
  name         = "vault-init-response"
  key_vault_id = data.azurerm_key_vault.argo.id
}

data "kubernetes_secret" "vault-token" {
  count = data.azurerm_key_vault_secret.vault-token.value == "" ? 1 : 0
  metadata {
    name = "vault-init-token"
    namespace = "vault"
  }
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
