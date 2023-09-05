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
  token           = data.azurerm_key_vault_secret.global-vault-token.value
  address         = "https://vault.${local.parent_domain}"
  alias           = "parent"
  skip_tls_verify = true
}

provider "vault" {
  address         = "http://vault-internal.vault:8200"
#  address         = "https://vault.${local.domain}"
  token           = local.vault_token
  skip_tls_verify = true
}

provider "postgresql" {
  host            = "postgres.postgres.svc"
  port            = 5432
  database        = "postgres"
  username        = "postgres"
  password        = data.kubernetes_secret.database_password.data["initialPassword"]
  sslmode         = "disable"
  connect_timeout = 15
}

provider "postgresql" {
  alias           = "qpc"
  host            = "${local.qpc_postgresql_fqdn}"
  port            = 5432
  database        = "postgres"
  username        = "psqladmin"
  password        = data.kubernetes_secret.qpc_postgresql_admin_password.data["admin_password"]
  sslmode         = "require"
  connect_timeout = 30
  superuser       = false
}

provider "elasticstack" {
  elasticsearch {
    username  = "elastic"
    password  = data.kubernetes_secret.elastic_password.data["elastic"]
    endpoints = ["https://elastic-search-es-http.elastic.svc:9200"]
    insecure = true
  }
}
