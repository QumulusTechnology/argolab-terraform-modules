resource "vault_database_secret_backend_role" "kamaji_postgres" {
  backend     = vault_database_secrets_mount.db.path
  db_name     = "kamaji"
  name        = "kamaji"
  default_ttl = 31536000
  max_ttl     = 31536000
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' INHERIT;",
    "ALTER USER \"{{name}}\" CREATEDB;",
    "ALTER USER \"{{name}}\" CREATEROLE;",
    "GRANT kamaji TO \"{{name}}\";",
    "GRANT ALL ON DATABASE kamaji TO kamaji;",
    "GRANT ALL PRIVILEGES ON SCHEMA PUBLIC TO kamaji;",
    "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA PUBLIC TO kamaji;",
    "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA PUBLIC TO kamaji;",
    "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA PUBLIC TO kamaji;",
  ]
  revocation_statements = [
    "REASSIGN OWNED BY \"{{name}}\" TO kamaji;",
    "DROP OWNED BY \"{{name}}\";"
  ]
}

resource "vault_policy" "kamaji_database_access" {
  name   = "kamaji-database-access"
  policy = <<EOT
path "database/creds/kamaji" {
  capabilities = [ "read" ]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "kamaji_database_access" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "kamaji-database-access"
  bound_service_account_names      = ["kamaji-database-credentials"]
  bound_service_account_namespaces = ["kamaji"]
  token_ttl                        = 31536000
  token_policies                   = ["kamaji-database-access"]
}
