resource "random_password" "vault_postgres_password" {
  length  = 36
  special = false
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

  elasticsearch {
    name              = "elastic"
    url               = "https://elastic-search-es-http.elastic.svc:9200"
    username          = elasticstack_elasticsearch_security_user.vault_user.username
    password          = random_password.vault_elasticsearch_password.result
    allowed_roles     = ["*"]
    insecure          = true
    verify_connection = false
  }

  postgresql {
    name           = postgresql_database.harbor.name
    connection_url = "postgres://{{username}}:{{password}}@postgres.postgres.svc:5432/${postgresql_database.harbor.name}"
    username       = postgresql_role.vault_harbor_role.name
    password       = random_password.vault_harbor_password.result
    allowed_roles  = ["*"]
  }

  postgresql {
    name           = postgresql_database.keycloak.name
    connection_url = "postgres://{{username}}:{{password}}@postgres.postgres.svc:5432/${postgresql_database.keycloak.name}"
    username       = postgresql_role.vault_keycloak_role.name
    password       = random_password.vault_keycloak_password.result
    allowed_roles  = ["*"]
  }

  postgresql {
    name           = "postgres"
    connection_url = "postgres://{{username}}:{{password}}@postgres.postgres.svc:5432/postgres"
    username       = postgresql_role.vault_postgres_role.name
    password       = random_password.vault_postgres_password.result
    allowed_roles  = ["*"]
  }

  postgresql {
    name           = postgresql_database.semaphore.name
    connection_url = "postgres://{{username}}:{{password}}@postgres.postgres.svc:5432/${postgresql_database.semaphore.name}"
    username       = postgresql_role.vault_semaphore_role.name
    password       = random_password.vault_semaphore_password.result
    allowed_roles  = ["*"]
  }
  postgresql {
    name           = postgresql_database.temporal.name
    connection_url = "postgres://{{username}}:{{password}}@postgres.postgres.svc:5432/${postgresql_database.temporal.name}"
    username       = postgresql_role.vault_temporal_role.name
    password       = random_password.vault_temporal_password.result
    allowed_roles  = ["*"]
  }
  postgresql {
    name           = postgresql_database.temporal_visibility.name
    connection_url = "postgres://{{username}}:{{password}}@postgres.postgres.svc:5432/${postgresql_database.temporal_visibility.name}"
    username       = postgresql_role.vault_temporal_visibility_role.name
    password       = random_password.vault_temporal_visibility_password.result
    allowed_roles  = ["*"]
  }

}
