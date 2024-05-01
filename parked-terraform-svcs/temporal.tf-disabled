
resource "vault_database_secret_backend_role" "temporal_postgres" {
  backend     = vault_database_secrets_mount.db.path
  db_name     = "temporal"
  name        = "temporal"
  default_ttl = 31536000
  max_ttl     = 31536000
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' INHERIT;",
    "GRANT temporal TO \"{{name}}\";",
    "GRANT ALL ON DATABASE TEMPORAL TO temporal;",
    "GRANT ALL PRIVILEGES ON SCHEMA PUBLIC TO temporal;",
    "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA PUBLIC TO temporal;",
    "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA PUBLIC TO temporal;",
    "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA PUBLIC TO temporal;",
  ]
  revocation_statements = [
    "REASSIGN OWNED BY \"{{name}}\" TO temporal;",
    "DROP OWNED BY \"{{name}}\";"
  ]
}

resource "elasticstack_elasticsearch_security_role" "temporal_role" {
  name    = "temporal-elastic"
  cluster = ["manage_index_templates"]
  indices {
    names      = ["temporal_visibility_*"]
    privileges = ["all"]
  }
}

resource "vault_database_secret_backend_role" "temporal_elastic" {
  backend     = vault_database_secrets_mount.db.path
  db_name     = vault_database_secrets_mount.db.elasticsearch[0].name
  name        = "temporal-elastic"
  default_ttl = 31536000
  max_ttl     = 31536000
  creation_statements = [
    "{\"elasticsearch_roles\": [\"${elasticstack_elasticsearch_security_role.temporal_role.name}\"]}",
  ]
}

resource "vault_policy" "temporal_database_access" {
  name   = "temporal-database-access"
  policy = <<EOT
path "database/creds/temporal" {
  capabilities = [ "read" ]
}
path "database/creds/temporal-elastic" {
  capabilities = [ "read" ]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "temporal" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "temporal-database-access"
  bound_service_account_names      = ["temporal-database-credentials"]
  bound_service_account_namespaces = ["temporal"]
  token_ttl                        = 31536000
  token_policies                   = ["temporal-database-access"]
}
