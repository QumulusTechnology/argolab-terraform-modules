
provider "azurerm" {
  client_id       = data.terraform_remote_state.argolab.outputs.openbao_init_client_id
  client_secret   = data.terraform_remote_state.argolab.outputs.openbao_init_client_secret
  subscription_id = local.subscription_id
  tenant_id       = local.tenant_id
  features {}
}

provider "azuread" {
  client_id       = data.terraform_remote_state.argolab.outputs.openbao_init_client_id
  client_secret   = data.terraform_remote_state.argolab.outputs.openbao_init_client_secret
  tenant_id = local.tenant_id

}

provider "aws" {
  region = "us-east-1"
  access_key = data.terraform_remote_state.argolab.outputs.openbao_iam_user_id
  secret_key = data.terraform_remote_state.argolab.outputs.openbao_iam_user_secret
}

provider "vault" {
  token           = var.openbao_parent_token
  address         = "https://vault.${local.parent_domain}"
  alias           = "parent"
  skip_tls_verify = true
}

provider "vault" {
  skip_tls_verify = true
}

provider "elasticstack" {
  elasticsearch {
    username  = "elastic"
    password  = data.kubernetes_secret.elastic_password.data["elastic"]
    endpoints = ["https://elasticsearch-es-http.elastic.svc:9200"]
    insecure  = true
  }
}
