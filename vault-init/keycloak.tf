resource "random_password" "vault_keycloak_password" {
  length           = 36
  special          = false
}

resource "postgresql_role" "vault_keycloak_role" {
  name             = "vault-keycloak-user"
  login            = true
  create_role      = true
  superuser        = true
  connection_limit = 5
  password         = random_password.vault_keycloak_password.result
}

resource "postgresql_role" "keycloak_role" {
  name             = "keycloak"
  login            = true
  create_role      = false
  superuser        = false
  connection_limit = 10
  lifecycle {
    ignore_changes = [password]
  }
}
resource "postgresql_database" "keycloak" {
  name              = "keycloak"
  owner             = postgresql_role.keycloak_role.name
  template          = "template0"
  lc_collate        = "en_US.UTF-8"
  lc_ctype          = "en_US.UTF-8"
  connection_limit  = -1
  allow_connections = true
}

resource "vault_database_secret_backend_role" "keycloak_postgres" {
  backend     = vault_database_secrets_mount.db.path
  db_name     = postgresql_database.keycloak.name
  name        = "keycloak"
  default_ttl = 31536000
  max_ttl     = 31536000
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' INHERIT;",
    "GRANT keycloak TO \"{{name}}\";",
    "GRANT ALL ON DATABASE keycloak TO keycloak;",
    "GRANT ALL PRIVILEGES ON SCHEMA PUBLIC TO keycloak;",
    "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA PUBLIC TO keycloak;",
    "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA PUBLIC TO keycloak;",
    "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA PUBLIC TO keycloak;",
  ]
  revocation_statements = [
    "REASSIGN OWNED BY \"{{name}}\" TO keycloak;",
    "DROP OWNED BY \"{{name}}\";"
  ]
}

resource "vault_policy" "keycloak_database_access" {
  name   = "keycloak-database-access"
  policy = <<EOT
path "database/creds/keycloak" {
  capabilities = [ "read" ]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "keycloak" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "keycloak-database-access"
  bound_service_account_names      = ["keycloak-database-credentials"]
  bound_service_account_namespaces = ["keycloak"]
  token_ttl                        = 31536000
  token_policies                   = ["keycloak-database-access"]
}
