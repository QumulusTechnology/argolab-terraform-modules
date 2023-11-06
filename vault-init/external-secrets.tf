resource "vault_kubernetes_auth_backend_role" "external_secrets" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "secrets-access"
  bound_service_account_names      = ["external-secrets-credentials"]
  bound_service_account_namespaces = ["external-secrets"]
  token_ttl                        = 31536000
  token_policies                   = ["secrets-access"]
}
