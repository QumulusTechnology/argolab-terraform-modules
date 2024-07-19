resource "vault_database_secret_backend_role" "pwpush_postgres" {
  backend     = vault_database_secrets_mount.db.path
  db_name     = "pwpush"
  name        = "pwpush"
  default_ttl = 31536000
  max_ttl     = 31536000
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' INHERIT;",
    "GRANT pwpush TO \"{{name}}\";",
    "GRANT ALL ON DATABASE pwpush TO pwpush;",
    "GRANT ALL PRIVILEGES ON SCHEMA PUBLIC TO pwpush;",
    "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA PUBLIC TO pwpush;",
    "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA PUBLIC TO pwpush;",
    "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA PUBLIC TO pwpush;",
  ]
  revocation_statements = [
    "REASSIGN OWNED BY \"{{name}}\" TO pwpush;",
    "DROP OWNED BY \"{{name}}\";"
  ]
}

resource "vault_policy" "pwpush_database_access" {
  name   = "pwpush-database-access"
  policy = <<EOT
path "database/creds/pwpush" {
  capabilities = [ "read" ]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "pwpush" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "pwpush-database-access"
  bound_service_account_names      = ["pwpush-database-credentials"]
  bound_service_account_namespaces = ["pwpush"]
  token_ttl                        = 31536000
  token_policies                   = ["pwpush-database-access"]
}
