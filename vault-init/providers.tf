terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.39.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.58.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.17.0"
    }
  }
}

provider "azurerm" {
  subscription_id = data.terraform_remote_state.argolab.outputs.subscription_id
  tenant_id       = data.terraform_remote_state.argolab.outputs.tenant_id
  features {}
}

provider "azuread" {
  tenant_id = data.terraform_remote_state.argolab.outputs.tenant_id
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.argolab.outputs.kube_host
  client_certificate     = data.terraform_remote_state.argolab.outputs.kube_client_certificate
  client_key             = data.terraform_remote_state.argolab.outputs.kube_client_key
  cluster_ca_certificate = data.terraform_remote_state.argolab.outputs.kube_cluster_ca_certificate
}

provider "vault" {
  #address = "https://${data.terraform_remote_state.argolab.outputs.parent_domain}"
  #token   = data.azurerm_key_vault_secret.global-vault-token[*].value
  address = "https://vault.${data.terraform_remote_state.argolab.outputs.domain}"
  token   = local.vault_token
  alias = "parent"
  skip_tls_verify = true
}

provider "vault" {
  address = "https://vault.${data.terraform_remote_state.argolab.outputs.domain}"
  token   = local.vault_token
  skip_tls_verify = true
}
