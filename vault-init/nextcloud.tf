resource "random_password" "vault_nextcloud_password" {
  length  = 36
  special = false
}

resource "postgresql_role" "vault_nextcloud_role" {
  name             = "vault-nextcloud-user"
  login            = true
  create_role      = true
  superuser        = true
  connection_limit = 5
  password         = random_password.vault_nextcloud_password.result
}

resource "postgresql_role" "nextcloud_role" {
  name             = "nextcloud"
  login            = true
  create_role      = false
  superuser        = false
  connection_limit = 10
  lifecycle {
    ignore_changes = [password]
  }
}
resource "postgresql_database" "nextcloud" {
  name              = "nextcloud"
  owner             = postgresql_role.nextcloud_role.name
  template          = "template0"
  lc_collate        = "en_US.UTF-8"
  lc_ctype          = "en_US.UTF-8"
  connection_limit  = -1
  allow_connections = true
}

resource "vault_database_secret_backend_role" "nextcloud_postgres" {
  backend     = vault_database_secrets_mount.db.path
  db_name     = postgresql_database.nextcloud.name
  name        = "nextcloud"
  default_ttl = 31536000
  max_ttl     = 31536000
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' INHERIT;",
    "GRANT nextcloud TO \"{{name}}\";",
    "GRANT ALL ON DATABASE nextcloud TO nextcloud;",
    "GRANT ALL PRIVILEGES ON SCHEMA PUBLIC TO nextcloud;",
    "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA PUBLIC TO nextcloud;",
    "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA PUBLIC TO nextcloud;",
    "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA PUBLIC TO nextcloud;",
  ]
  revocation_statements = [
    "REASSIGN OWNED BY \"{{name}}\" TO nextcloud;",
    "DROP OWNED BY \"{{name}}\";"
  ]
}

resource "vault_policy" "nextcloud_database_access" {
  name   = "nextcloud-database-access"
  policy = <<EOT
path "database/creds/nextcloud" {
  capabilities = [ "read" ]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "nextcloud" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "nextcloud-database-access"
  bound_service_account_names      = ["nextcloud-database-credentials"]
  bound_service_account_namespaces = ["nextcloud"]
  token_ttl                        = 31536000
  token_policies                   = ["nextcloud-database-access"]
}
