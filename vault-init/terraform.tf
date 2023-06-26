terraform {
  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.49.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.36.0"
    }
    vault = {
      source                = "hashicorp/vault"
      version               = ">= 3.17.0"
    }
  }
}
