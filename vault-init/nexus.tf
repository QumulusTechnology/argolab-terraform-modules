

resource "vault_database_secret_backend_role" "nexus_postgres" {
  backend     = vault_database_secrets_mount.db.path
  db_name     = "nexus"
  name        = "nexus"
  default_ttl = 31536000
  max_ttl     = 31536000
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' INHERIT;",
    "GRANT nexus TO \"{{name}}\";",
    "GRANT ALL ON DATABASE nexus TO nexus;",
    "GRANT ALL PRIVILEGES ON SCHEMA PUBLIC TO nexus;",
    "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA PUBLIC TO nexus;",
    "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA PUBLIC TO nexus;",
    "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA PUBLIC TO nexus;",
  ]
  revocation_statements = [
    "REASSIGN OWNED BY \"{{name}}\" TO nexus;",
    "DROP OWNED BY \"{{name}}\";"
  ]
}

resource "vault_policy" "nexus_database_access" {
  name   = "nexus-database-access"
  policy = <<EOT
path "database/creds/nexus" {
  capabilities = [ "read" ]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "nexus" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "nexus-database-access"
  bound_service_account_names      = ["nexus-database-credentials"]
  bound_service_account_namespaces = ["nexus"]
  token_ttl                        = 31536000
  token_policies                   = ["nexus-database-access"]
}
