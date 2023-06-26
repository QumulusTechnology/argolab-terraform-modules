provider "azurerm" {
  subscription_id = local.subscription_id
  tenant_id       = local.tenant_id
  features {}
}

provider "azuread" {
  tenant_id = local.tenant_id
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.argolab.outputs.kube_host
  client_certificate     = data.terraform_remote_state.argolab.outputs.kube_client_certificate
  client_key             = data.terraform_remote_state.argolab.outputs.kube_client_key
  cluster_ca_certificate = data.terraform_remote_state.argolab.outputs.kube_cluster_ca_certificate
}

provider "vault" {
  token   = data.azurerm_key_vault_secret.global-vault-token.value
  address = "https://vault.${local.parent_domain}"
  alias = "parent"
  skip_tls_verify = true
}

provider "vault" {
  address = "http://vault-internal.vault:8200"
  token   = local.vault_token
  skip_tls_verify = true
}
