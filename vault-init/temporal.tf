resource "random_password" "vault_temporal_password" {
  length           = 24
  special          = true
  override_special = "!@#%^&*()_-+={}[]"
}

resource "random_password" "vault_temporal_visibility_password" {
  length           = 24
  special          = true
  override_special = "!@#%^&*()_-+={}[]"
}

resource "postgresql_role" "vault_temporal_role" {
  name             = "vault-temporal-user"
  login            = true
  create_role      = true
  superuser        = true
  connection_limit = 5
  password         = random_password.vault_temporal_password.result
}

resource "postgresql_role" "vault_temporal_visibility_role" {
  name             = "vault-temporal-visibility-user"
  login            = true
  superuser        = true
  create_role      = true
  connection_limit = 5
  password         = random_password.vault_temporal_visibility_password.result
}

resource "postgresql_role" "temporal_role" {
  name             = "temporal"
  login            = false
  superuser        = false
  create_role      = false
  connection_limit = 20
}

resource "postgresql_database" "temporal" {
  name              = "temporal"
  owner             = postgresql_role.temporal_role.name
  template          = "template0"
  lc_collate        = "DEFAULT"
  connection_limit  = -1
  allow_connections = true
}

resource "postgresql_database" "temporal_visibility" {
  name              = "temporal_visibility"
  owner             = postgresql_role.temporal_role.name
  template          = "template0"
  lc_collate        = "DEFAULT"
  connection_limit  = -1
  allow_connections = true
}


resource "vault_database_secret_backend_role" "temporal_postgres" {
  backend     = vault_database_secrets_mount.db.path
  db_name     = "temporal"
  name        = "temporal_postgres"
  default_ttl = 31536000
  max_ttl     = 31536000
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' INHERIT;",
    "GRANT temporal TO \"{{name}}\";",
    "GRANT ALL ON DATABASE TEMPORAL TO TEMPORAL;",
    "GRANT ALL PRIVILEGES ON SCHEMA PUBLIC TO TEMPORAL;",
    "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA PUBLIC TO TEMPORAL;",
    "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA PUBLIC TO TEMPORAL;",
    "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA PUBLIC TO TEMPORAL;",
  ]
}

resource "vault_database_secret_backend_role" "temporal_visibility_postgres" {
  backend     = vault_database_secrets_mount.db.path
  db_name     = "temporal_visibility"
  name        = "temporal_visibility_postgres"
  default_ttl = 31536000
  max_ttl     = 31536000
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' INHERIT;",
    "GRANT temporal TO \"{{name}}\";",
    "GRANT ALL ON DATABASE TEMPORAL_VISIBILITY TO TEMPORAL;",
    "GRANT ALL PRIVILEGES ON SCHEMA PUBLIC TO TEMPORAL;",
    "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA PUBLIC TO TEMPORAL;",
    "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA PUBLIC TO TEMPORAL;",
    "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA PUBLIC TO TEMPORAL;",
  ]
}

resource "elasticstack_elasticsearch_security_role" "temporal_role" {
  name    = "temporal-role"
  cluster = ["manage_index_templates"]
  indices {
    names      = ["temporal_visibility_*"]
    privileges = ["all"]
  }
}

resource "vault_database_secret_backend_role" "temporal_elastic" {
  backend     = vault_database_secrets_mount.db.path
  db_name     = vault_database_secrets_mount.db.elasticsearch[0].name
  name        = "temporal_elastic"
  default_ttl = 31536000
  max_ttl     = 31536000
  creation_statements = [
    "{\"elasticsearch_roles\": [\"${elasticstack_elasticsearch_security_role.temporal_role.name}\"]}",
  ]
}

resource "vault_policy" "temporal_database_access" {
  name   = "temporal-database-access"
  policy = <<EOT
path "database/creds/temporal_postgres" {
  capabilities = [ "read" ]
}
path "database/creds/temporal_visibility_postgres" {
  capabilities = [ "read" ]
}
path "database/creds/temporal_elastic" {
  capabilities = [ "read" ]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "temporal" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "temporal-database-access"
  bound_service_account_names      = ["temporal-database-credentials"]
  bound_service_account_namespaces = ["temporal"]
  token_ttl                        = 3600
  token_policies                   = ["temporal-database-access"]
}
