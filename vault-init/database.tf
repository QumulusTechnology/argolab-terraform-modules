resource "vault_database_secrets_mount" "db" {
  path = "database"
  postgresql {
    name           = "postgres"
    connection_url = "postgres://{{username}}:${data.kubernetes_secret.database_password.data["initialPassword"]}@postgres.database.svc:5432/postgres"
    username       = "postgres"
    password       = data.kubernetes_secret.database_password.data["initialPassword"]
    allowed_roles  = ["harbor", "keycloak"]
  }
}

resource "vault_database_secret_backend_static_role" "harbor" {
  name                = "harbor"
  backend             = vault_database_secrets_mount.db.path
  db_name             = vault_database_secrets_mount.db.postgresql[0].name
  username            = "harbor"
  rotation_period     = "31536000"
  rotation_statements = ["ALTER USER \"{{username}}\" WITH PASSWORD '{{password}}';"]
}


resource "vault_policy" "harbor_database_access" {
  name   = "harbor-database-access"
  policy = <<EOT
path "database/static-creds/harbor" {
  capabilities = [ "read" ]
}
EOT
}

resource "vault_database_secret_backend_static_role" "keycloak" {
  name                = "keycloak"
  backend             = vault_database_secrets_mount.db.path
  db_name             = vault_database_secrets_mount.db.postgresql[0].name
  username            = "keycloak"
  rotation_period     = "3600"
  rotation_statements = ["ALTER USER \"{{username}}\" WITH PASSWORD '{{password}}';"]
}

resource "vault_policy" "keycloak_database_access" {
  name   = "keycloak-database-access"
  policy = <<EOT
path "database/static-creds/keycloak" {
  capabilities = [ "read" ]
}
EOT
}
