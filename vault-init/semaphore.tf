resource "vault_database_secret_backend_role" "semaphore_postgres" {
  backend     = vault_database_secrets_mount.db.path
  db_name     = "semaphore"
  name        = "semaphore"
  default_ttl = 31536000
  max_ttl     = 31536000
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' INHERIT;",
    "GRANT semaphore TO \"{{name}}\";",
    "GRANT ALL ON DATABASE semaphore TO semaphore;",
    "GRANT ALL PRIVILEGES ON SCHEMA PUBLIC TO semaphore;",
    "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA PUBLIC TO semaphore;",
    "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA PUBLIC TO semaphore;",
    "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA PUBLIC TO semaphore;",
  ]
  revocation_statements = [
    "REASSIGN OWNED BY \"{{name}}\" TO semaphore;",
    "DROP OWNED BY \"{{name}}\";"
  ]
}

resource "vault_policy" "semaphore_database_access" {
  name   = "semaphore-database-access"
  policy = <<EOT
path "database/creds/semaphore" {
  capabilities = [ "read" ]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "semaphore_database_access" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "semaphore-database-access"
  bound_service_account_names      = ["semaphore-database-credentials"]
  bound_service_account_namespaces = ["semaphore"]
  token_ttl                        = 31536000
  token_policies                   = ["semaphore-database-access"]
}

resource "vault_kubernetes_auth_backend_role" "semaphore_runner" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "semaphore-runner"
  bound_service_account_names      = ["semaphore-runner"]
  bound_service_account_namespaces = ["semaphore"]
  token_ttl                        = 3600
  token_policies                   = ["semaphore-runner"]
}
