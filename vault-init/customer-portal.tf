

resource "vault_database_secret_backend_role" "customerportal_postgres" {
  backend     = vault_database_secrets_mount.db.path
  db_name     = "customerportal"
  name        = "customerportal"
  default_ttl = 31536000
  max_ttl     = 31536000
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' INHERIT;",
    "GRANT \"customerportal\" TO \"{{name}}\";",
    "GRANT ALL ON DATABASE \"customerportal\" TO \"customerportal\";",
    "GRANT ALL PRIVILEGES ON SCHEMA PUBLIC TO customerportal;",
    "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA PUBLIC TO \"customerportal\";",
    "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA PUBLIC TO \"customerportal\";",
    "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA PUBLIC TO \"customerportal\";",
  ]
  revocation_statements = [
    "REASSIGN OWNED BY \"{{name}}\" TO \"customerportal\";",
    "DROP OWNED BY \"{{name}}\";"
  ]
}

resource "vault_policy" "customerportal_database_access" {
  name   = "customerportal-database-access"
  policy = <<EOT
path "database/creds/customerportal" {
  capabilities = [ "read" ]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "customerportal" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "customerportal-database-access"
  bound_service_account_names      = ["customerportal-database-credentials"]
  bound_service_account_namespaces = ["customer-portal"]
  token_ttl                        = 31536000
  token_policies                   = ["customerportal-database-access"]
}
