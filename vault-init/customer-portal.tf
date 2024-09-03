

resource "vault_database_secret_backend_role" "customer-portal_postgres" {
  backend     = vault_database_secrets_mount.db.path
  db_name     = "customer-portal"
  name        = "customer-portal"
  default_ttl = 31536000
  max_ttl     = 31536000
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' INHERIT;",
    "GRANT customer-portal TO \"{{name}}\";",
    "GRANT ALL ON DATABASE customer-portal TO customer-portal;",
    "GRANT ALL PRIVILEGES ON SCHEMA PUBLIC TO customer-portal;",
    "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA PUBLIC TO customer-portal;",
    "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA PUBLIC TO customer-portal;",
    "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA PUBLIC TO customer-portal;",
  ]
  revocation_statements = [
    "REASSIGN OWNED BY \"{{name}}\" TO customer-portal;",
    "DROP OWNED BY \"{{name}}\";"
  ]
}

resource "vault_policy" "customer-portal_database_access" {
  name   = "customer-portal-database-access"
  policy = <<EOT
path "database/creds/customer-portal" {
  capabilities = [ "read" ]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "customer-portal" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "customer-portal-database-access"
  bound_service_account_names      = ["customer-portal-database-credentials"]
  bound_service_account_namespaces = ["customer-portal"]
  token_ttl                        = 31536000
  token_policies                   = ["customer-portal-database-access"]
}
