
# resource "vault_database_secret_backend_role" "harbor_postgres" {
#   backend     = vault_database_secrets_mount.db.path
#   db_name     = "harbor"
#   name        = "harbor"
#   default_ttl = 31536000
#   max_ttl     = 31536000
#   creation_statements = [
#     "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' INHERIT;",
#     "GRANT harbor TO \"{{name}}\";",
#     "GRANT ALL ON DATABASE harbor TO harbor;",
#     "GRANT ALL PRIVILEGES ON SCHEMA PUBLIC TO harbor;",
#     "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA PUBLIC TO harbor;",
#     "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA PUBLIC TO harbor;",
#     "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA PUBLIC TO harbor;",
#   ]
#   revocation_statements = [
#     "REASSIGN OWNED BY \"{{name}}\" TO harbor;",
#     "DROP OWNED BY \"{{name}}\";"
#   ]
# }

# resource "vault_policy" "harbor_database_access" {
#   name   = "harbor-database-access"
#   policy = <<EOT
# path "database/creds/harbor" {
#   capabilities = [ "read" ]
# }
# EOT
# }

# resource "vault_kubernetes_auth_backend_role" "harbor" {
#   backend                          = vault_auth_backend.kubernetes.path
#   role_name                        = "harbor-database-access"
#   bound_service_account_names      = ["harbor-database-credentials"]
#   bound_service_account_namespaces = ["harbor"]
#   token_ttl                        = 31536000
#   token_policies                   = ["harbor-database-access"]
# }
