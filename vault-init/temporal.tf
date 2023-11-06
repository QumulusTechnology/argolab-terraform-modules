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
  lifecycle {
    ignore_changes = [password]
  }
}

resource "postgresql_database" "temporal" {
  name              = "temporal"
  owner             = postgresql_role.temporal_role.name
  template          = "template0"
  lc_collate        = "en_US.UTF-8"
  lc_ctype          = "en_US.UTF-8"
  connection_limit  = -1
  allow_connections = true
}

resource "vault_database_secret_backend_role" "temporal_postgres" {
  backend     = vault_database_secrets_mount.db.path
  db_name     = postgresql_database.temporal.name
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

resource "postgresql_role" "temporal_visibility_role" {
  name             = "temporal-visibility"
  login            = false
  superuser        = false
  create_role      = false
  connection_limit = 20
  lifecycle {
    ignore_changes = [password]
  }
}

resource "postgresql_database" "temporal_visibility" {
  name              = "temporal-visibility"
  owner             = postgresql_role.temporal_visibility_role.name
  template          = "template0"
  lc_collate        = "en_US.UTF-8"
  lc_ctype          = "en_US.UTF-8"
  connection_limit  = -1
  allow_connections = true
}

resource "vault_database_secret_backend_role" "temporal_visibility_postgres" {
  backend     = vault_database_secrets_mount.db.path
  db_name     = postgresql_database.temporal_visibility.name
  name        = "temporal-visibility"
  default_ttl = 31536000
  max_ttl     = 31536000
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' INHERIT;",
    "GRANT \"temporal-visibility\" TO \"{{name}}\";",
    "GRANT ALL ON DATABASE \"temporal-visibility\" TO \"temporal-visibility\";",
    "GRANT ALL PRIVILEGES ON SCHEMA PUBLIC TO \"temporal-visibility\";",
    "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA PUBLIC TO \"temporal-visibility\";",
    "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA PUBLIC TO \"temporal-visibility\";",
    "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA PUBLIC TO  \"temporal-visibility\";",
  ]
  revocation_statements = [
    "REASSIGN OWNED BY  \"{{name}}\" TO \"temporal-visibility\";",
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
path "database/creds/temporal-visibility" {
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
