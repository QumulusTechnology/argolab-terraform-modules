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

resource "vault_kubernetes_auth_backend_role" "harbor" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "harbor-database-access"
  bound_service_account_names      = ["harbor-database-credentials"]
  bound_service_account_namespaces = ["harbor"]
  token_ttl                        = 3600
  token_policies                   = ["harbor-database-access"]
}
