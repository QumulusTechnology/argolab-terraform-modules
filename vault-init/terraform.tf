terraform {
  required_providers {
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
