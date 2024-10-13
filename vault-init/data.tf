
data "kubernetes_secret" "zabbix_postgres_password" {
  metadata {
    name      = "zabbix-db-superuser"
    namespace = "zabbix"
  }
}

data "kubernetes_secret" "harbor_postgres_password" {
  metadata {
    name      = "harbor-db-superuser"
    namespace = "harbor"
  }
}

data "kubernetes_secret" "kamaji_postgres_password" {
  metadata {
    name      = "kamaji-db-superuser"
    namespace = "kamaji"
  }
}

data "kubernetes_secret" "keycloak_postgres_password" {
  metadata {
    name      = "keycloak-db-superuser"
    namespace = "keycloak"
  }
}

data "kubernetes_secret" "nexus_postgres_password" {
  metadata {
    name      = "nexus-db-superuser"
    namespace = "nexus"
  }
}

data "kubernetes_secret" "pwpush_postgres_password" {
  metadata {
    name      = "pwpush-db-superuser"
    namespace = "pwpush"
  }
}

# data "kubernetes_secret" "semaphore_postgres_password" {
#   metadata {
#     name      = "semaphore-db-superuser"
#     namespace = "semaphore"
#   }
# }

data "kubernetes_secret" "temporal_postgres_password" {
  metadata {
    name      = "temporal-db-superuser"
    namespace = "temporal"
  }
}

data "kubernetes_secret" "elastic_password" {
  metadata {
    name      = "elasticsearch-es-elastic-user"
    namespace = "elastic"
  }
}

data "terraform_remote_state" "argolab" {
  backend = "s3"
  config = {
    bucket = "qumulus-terraform-state-backend-${var.environment}"
    key    = "${var.branch}/argolab"
    region = "us-east-1"
  }
}

data "external" "vault_init" {
  program = [
    "${path.module}/scripts/wait_for_vault.sh"
  ]
}
