resource "random_password" "vault_harbor_password" {
  length           = 36
  special          = false
}

resource "postgresql_role" "vault_harbor_role" {
  name             = "vault-harbor-user"
  login            = true
  create_role      = true
  superuser        = true
  connection_limit = 5
  password         = random_password.vault_harbor_password.result
}

resource "postgresql_role" "harbor_role" {
  name             = "harbor"
  login            = true
  create_role      = false
  superuser        = false
  connection_limit = 10
  lifecycle {
    ignore_changes = [password]
  }
}
resource "postgresql_database" "harbor" {
  name              = "harbor"
  owner             = postgresql_role.harbor_role.name
  template          = "template0"
  lc_collate        = "en_US.UTF-8"
  lc_ctype          = "en_US.UTF-8"
  connection_limit  = -1
  allow_connections = true
}

resource "vault_database_secret_backend_role" "harbor_postgres" {
  backend     = vault_database_secrets_mount.db.path
  db_name     = postgresql_database.harbor.name
  name        = "harbor"
  default_ttl = 31536000
  max_ttl     = 31536000
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' INHERIT;",
    "GRANT harbor TO \"{{name}}\";",
    "GRANT ALL ON DATABASE harbor TO harbor;",
    "GRANT ALL PRIVILEGES ON SCHEMA PUBLIC TO harbor;",
    "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA PUBLIC TO harbor;",
    "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA PUBLIC TO harbor;",
    "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA PUBLIC TO harbor;",
  ]
  revocation_statements = [
    "REASSIGN OWNED BY \"{{name}}\" TO harbor;",
    "DROP OWNED BY \"{{name}}\";"
  ]
}

resource "vault_policy" "harbor_database_access" {
  name   = "harbor-database-access"
  policy = <<EOT
path "database/creds/harbor" {
  capabilities = [ "read" ]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "harbor" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "harbor-database-access"
  bound_service_account_names      = ["harbor-database-credentials"]
  bound_service_account_namespaces = ["harbor"]
  token_ttl                        = 31536000
  token_policies                   = ["harbor-database-access"]
}
