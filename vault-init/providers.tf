# provider "azurerm" {
#   subscription_id = local.subscription_id
#   tenant_id       = local.tenant_id
#   features {}
# }

provider "aws" {
  region     = "eu-west-1"
}

# provider "azuread" {
#   tenant_id = local.tenant_id
# }

provider "kubernetes" {
  host                   = data.terraform_remote_state.argolab.outputs.kube_host
  client_certificate     = data.terraform_remote_state.argolab.outputs.kube_client_certificate
  client_key             = data.terraform_remote_state.argolab.outputs.kube_client_key
  cluster_ca_certificate = data.terraform_remote_state.argolab.outputs.kube_cluster_ca_certificate
}

provider "vault" {
  token           = jsondecode(data.aws_secretsmanager_secret_version.global_vault_token_secret_string.secret_string)["vault-token"]
  address         = "https://vault.${local.parent_domain}"
  alias           = "parent"
  skip_tls_verify = true
}

provider "vault" {
  address         = "http://vault-internal.vault:8200"
  token           = var.vault_token
  skip_tls_verify = true
}


provider "elasticstack" {
  elasticsearch {
    username  = "elastic"
    password  = data.kubernetes_secret.elastic_password.data["elastic"]
    endpoints = ["https://elastic-search-es-http.elastic.svc:9200"]
    insecure  = true
  }
}
