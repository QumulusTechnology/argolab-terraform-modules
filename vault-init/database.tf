resource "random_password" "vault_postgres_password" {
  length           = 24
  special          = true
  override_special = "!@#%^&*()_-+={}[]"
}

resource "postgresql_role" "vault_postgres_role" {
  name             = "vault-postgres-user"
  login            = true
  create_role      = true
  superuser        = true
  connection_limit = 5
  password         = random_password.vault_postgres_password.result
}

resource "vault_database_secrets_mount" "db" {
  path = "database"
  postgresql {
    name           = "postgres"
    connection_url = "postgres://{{username}}:{{password}}@postgres.postgres.svc:5432/postgres"
    username       = postgresql_role.vault_postgres_role.name
    password       = random_password.vault_postgres_password.result
    allowed_roles  = ["*"]
  }
  postgresql {
    name           = "temporal"
    connection_url = "postgres://{{username}}:{{password}}@postgres.postgres.svc:5432/${postgresql_database.temporal.name}"
    username       = postgresql_role.vault_temporal_role.name
    password       = random_password.vault_temporal_password.result
    allowed_roles  = ["*"]
  }
  postgresql {
    name           = "temporal_visibility"
    connection_url = "postgres://{{username}}:{{password}}@postgres.postgres.svc:5432/${postgresql_database.temporal_visibility.name}"
    username       = postgresql_role.vault_temporal_visibility_role.name
    password       = random_password.vault_temporal_visibility_password.result
    allowed_roles  = ["*"]
  }
  postgresql {
    name              = "qpc"
    username          = "psqladmin"
    password          = random_password.qpc_postgres_password.result
    connection_url    = "postgres://{{username}}:{{password}}@${azurerm_postgresql_flexible_server.qpc.fqdn}:5432/${azurerm_postgresql_flexible_server_database.	qpc.name}?sslmode=require"
    verify_connection = true
    allowed_roles = [
      "qpc",
    ]
  }
  elasticsearch {
    name              = "elastic"
    url               = "https://elastic-search-es-http.elastic.svc:9200"
    username          = elasticstack_elasticsearch_security_user.vault_user.username
    password          = random_password.vault_elasticsearch_password.result
    allowed_roles     = ["*"]
    insecure          = true
    verify_connection = false
  }
}
