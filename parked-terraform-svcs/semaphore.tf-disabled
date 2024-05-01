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

#Long TTL until re resolve multi sources issue on ArgoLab
resource "vault_azure_secret_backend_role" "semaphore" {
  backend = vault_azure_secret_backend.this.path
  role    = "semaphore-azure-access"
  ttl     = "31536000"
  max_ttl = "31536000"
  azure_groups {
    group_name = "Semaphore Access"
  }
}

resource "vault_policy" "semaphore" {
  name = "semaphore-azure-access"

  policy = <<EOT
path "${vault_azure_secret_backend.this.path}/creds/${vault_azure_secret_backend_role.semaphore.role}" {
  capabilities = ["read"]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "semaphore_azure_access" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "semaphore-azure-access"
  bound_service_account_names      = ["semaphore-azure-credentials"]
  bound_service_account_namespaces = ["semaphore"]
  token_ttl                        = 31536000
  token_policies                   = ["semaphore-azure-access"]
}
