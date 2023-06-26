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
  host                   = data.terraform_remote_state.argolab.outputs.host
  client_certificate     = data.terraform_remote_state.argolab.outputs.client_certificate
  client_key             = data.terraform_remote_state.argolab.outputs.client_key
  cluster_ca_certificate = data.terraform_remote_state.argolab.outputs.cluster_ca_certificate
}
