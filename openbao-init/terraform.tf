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
      source  = "hashicorp/vault"
      version = ">= 3.22.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.20.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
    elasticstack = {
      source  = "elastic/elasticstack"
      version = ">= 0.6.2"
    }
  }
}
