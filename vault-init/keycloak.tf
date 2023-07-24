resource "vault_database_secret_backend_static_role" "keycloak" {
  name                = "keycloak"
  backend             = vault_database_secrets_mount.db.path
  db_name             = vault_database_secrets_mount.db.postgresql[0].name
  username            = "keycloak"
  rotation_period     = "3600"
  rotation_statements = ["ALTER USER \"{{username}}\" WITH PASSWORD '{{password}}';"]
}


resource "vault_policy" "keycloak_database_access" {
  name   = "keycloak-database-access"
  policy = <<EOT
path "database/static-creds/keycloak" {
  capabilities = [ "read" ]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "keycloak" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "keycloak-database-access"
  bound_service_account_names      = ["keycloak-database-credentials"]
  bound_service_account_namespaces = ["keycloak"]
  token_ttl                        = 3600
  token_policies                   = ["keycloak-database-access"]
}
