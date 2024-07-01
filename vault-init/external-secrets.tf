resource "vault_policy" "external-secrets" {
  name = "external-secrets-access"

  policy = <<EOT
path "${vault_kubernetes_auth_backend_role.external-secrets.path}/creds/${vault_azure_secret_backend_role.external-secrets.role}" {
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
