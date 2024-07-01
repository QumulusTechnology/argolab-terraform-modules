resource "vault_mount" "kvv2-example" {
  path        = "cluster"
  type        = "kv-v2"
  options = {
    version = "2"
    type    = "kv-v2"
  }
  description = "Cluster secrets"
}

resource "vault_policy" "external-secrets" {
  name = "external-secrets-access"

  policy = <<EOT
path "kubernetes/creds/external-secrets" {
  capabilities = ["read"]
}
path "cluster/*" {
  capabilities = ["read", "create", "update", "delete"]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "external-secrets" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "external-secrets-access"
  bound_service_account_names      = ["external-secrets-credentials"]
  bound_service_account_namespaces = ["external-secrets"]
  token_ttl                        = 31536000
  token_policies                   = ["external-secrets-access"]
}
