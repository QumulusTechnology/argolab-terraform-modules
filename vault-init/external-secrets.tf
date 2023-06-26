resource "vault_kubernetes_auth_backend_role" "external_secrets" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "secrets-access"
  bound_service_account_names      = ["external-secrets-credentials"]
  bound_service_account_namespaces = ["external-secrets"]
  token_ttl                        = 3600
  token_policies                   = ["secrets-access"]
}


resource "vault_kubernetes_auth_backend_role" "keycloak" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "keycloak-database-access"
  bound_service_account_names      = ["keycloak-database-credentials"]
  bound_service_account_namespaces = ["keycloak"]
  token_ttl                        = 3600
  token_policies                   = ["keycloak-database-access"]
}

resource "vault_kubernetes_auth_backend_role" "harbor" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "harbor-database-access"
  bound_service_account_names      = ["harbor-database-credentials"]
  bound_service_account_namespaces = ["harbor"]
  token_ttl                        = 3600
  token_policies                   = ["harbor-database-access"]
}
