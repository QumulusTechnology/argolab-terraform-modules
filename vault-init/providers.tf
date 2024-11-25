provider "vault" {
  token           = var.vault_parent_token
  address         = "https://vault.${local.parent_domain}"
  alias           = "parent"
  skip_tls_verify = true
}

provider "vault" {
  skip_tls_verify = true
}

# provider "elasticstack" {
#   elasticsearch {
#     username  = "elastic"
#     password  = data.kubernetes_secret.elastic_password.data["elastic"]
#     endpoints = ["https://elasticsearch-es-http.elastic.svc:9200"]
#     insecure  = true
#   }
# }
