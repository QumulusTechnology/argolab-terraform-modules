data "azurerm_key_vault" "global" {
  name                = local.keyvault_name_global
  resource_group_name = "global"
}

data "azurerm_key_vault" "argo" {
  name                = local.keyvault_name_argo
  resource_group_name = local.resource_group_name
}

data "azurerm_key_vault_secret" "global-vault-token" {
  name         = "vault-token"
  key_vault_id = data.azurerm_key_vault.global.id
}

data "kubernetes_secret" "database_password" {
  metadata {
    name      = "postgres-auth"
    namespace = "postgres"
  }
}

data "kubernetes_secret" "elastic_password" {
  metadata {
    name      = "elastic-search-es-elastic-user"
    namespace = "elastic"
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

data "kubernetes_secret" "azure-sso-credentials" {
  metadata {
    name      = "azure-sso-credentials"
    namespace = "vault"
  }
}

data "terraform_remote_state" "argolab" {
  backend = "azurerm"
  config = {
    resource_group_name  = "global"
    storage_account_name = "${var.global_storage_account_name}"
    container_name       = "tfstate"
    key                  = "${var.terraform_state_backend_key}/argolab"
    subscription_id      = "${var.subscription_id}"
    tenant_id            = "${var.tenant_id}"
    use_oidc             = true
  }
}

data "external" "vault_init" {
  program = [
    "${path.module}/scripts/wait_for_vault.sh",
    data.terraform_remote_state.argolab.outputs.kube_host,
    base64encode(data.terraform_remote_state.argolab.outputs.kube_client_certificate),
    base64encode(data.terraform_remote_state.argolab.outputs.kube_client_key),
    base64encode(data.terraform_remote_state.argolab.outputs.kube_cluster_ca_certificate),
  ]
}
