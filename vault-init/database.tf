resource "vault_database_secrets_mount" "db" {
  path = "database"

  ### Note these should be in alphabetical order to prevent terraform from trying to reorder the databases by each apply
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
    name           = "harbor"
    connection_url = "postgres://{{username}}:{{password}}@harbor-db-rw.harbor.svc:5432/harbor"
    username       = data.kubernetes_secret.harbor_postgres_password.data["username"]
    password       = data.kubernetes_secret.harbor_postgres_password.data["password"]
    allowed_roles  = ["*"]
  }

  # postgresql {
  #   name           = "kamaji"
  #   connection_url = "postgres://{{username}}:{{password}}@kamaji-db-rw.kamaji.svc:5432/kamaji"
  #   username       = data.kubernetes_secret.kamaji_postgres_password.data["username"]
  #   password       = data.kubernetes_secret.kamaji_postgres_password.data["password"]
  #   allowed_roles  = ["*"]
  # }

  postgresql {
    name           = "keycloak"
    connection_url = "postgres://{{username}}:{{password}}@keycloak-db-rw.keycloak.svc:5432/keycloak"
    username       = data.kubernetes_secret.keycloak_postgres_password.data["username"]
    password       = data.kubernetes_secret.keycloak_postgres_password.data["password"]
    allowed_roles  = ["*"]
  }

  postgresql {
    name           = "nexus"
    connection_url = "postgres://{{username}}:{{password}}@nexus-db-rw.nexus.svc:5432/nexus"
    username       = data.kubernetes_secret.nexus_postgres_password.data["username"]
    password       = data.kubernetes_secret.nexus_postgres_password.data["password"]
    allowed_roles  = ["*"]
  }

  postgresql {
    name           = "pwpush"
    connection_url = "postgres://{{username}}:{{password}}@pwpush-db-rw.pwpush.svc:5432/pwpush"
    username       = data.kubernetes_secret.pwpush_postgres_password.data["username"]
    password       = data.kubernetes_secret.pwpush_postgres_password.data["password"]
    allowed_roles  = ["*"]
  }

  postgresql {
    name           = "semaphore"
    connection_url = "postgres://{{username}}:{{password}}@semaphore-db-rw.semaphore.svc:5432/semaphore"
    username       = data.kubernetes_secret.semaphore_postgres_password.data["username"]
    password       = data.kubernetes_secret.semaphore_postgres_password.data["password"]
    allowed_roles  = ["*"]
  }

  postgresql {
    name           = "temporal"
    connection_url = "postgres://{{username}}:{{password}}@temporal-db-rw.temporal.svc:5432/temporal"
    username       = data.kubernetes_secret.temporal_postgres_password.data["username"]
    password       = data.kubernetes_secret.temporal_postgres_password.data["password"]
    allowed_roles  = ["*"]
  }

}
