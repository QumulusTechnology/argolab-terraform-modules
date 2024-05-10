# data "azurerm_key_vault" "global" {
#   name                = local.keyvault_name_global
#   resource_group_name = "global"
# }

# data "azurerm_key_vault" "argo" {
#   name                = local.keyvault_name_argo
#   resource_group_name = local.resource_group_name
# }

data "aws_secretsmanager_secret" "global-vault-token" {
  name = "/dev/global/vault-token"
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

data "kubernetes_secret" "semaphore_postgres_password" {
  metadata {
    name      = "semaphore-db-superuser"
    namespace = "semaphore"
  }
}

data "kubernetes_secret" "temporal_postgres_password" {
  metadata {
    name      = "temporal-db-superuser"
    namespace = "temporal"
  }
}

data "kubernetes_secret" "elastic_password" {
  metadata {
    name      = "elastic-search-es-elastic-user"
    namespace = "elastic"
  }
}

# data "vault_identity_group" "vault_admins" {
#   group_name = "Vault Admins"
#   depends_on = [
#     module.vault_azure_ad_groups
#   ]
# }

# data "vault_identity_group" "engineering" {
#   group_name = "Engineering"
#   depends_on = [
#     module.vault_azure_ad_groups
#   ]
# }

# data "vault_identity_group" "devops" {
#   group_name = "DevOps"
#   depends_on = [
#     module.vault_azure_ad_groups
#   ]
# }

# data "kubernetes_secret" "azure-sso-credentials" {
#   metadata {
#     name      = "azure-sso-credentials"
#     namespace = "vault"
#   }
# }

data "terraform_remote_state" "argolab" {
  backend = "s3"
  config = {
    bucket  = "qumulusglobaldevtest" #Make this dynamic
    key     = "refactor/argolab" #Make this dynamic
    region  = "eu-west-2" #Make this dynamic
  }
}

data "external" "vault_init" {
  program = [
    "${path.module}/scripts/wait_for_vault.sh",
    data.terraform_remote_state.argolab.outputs.kube_host,
    base64encode(data.terraform_remote_state.argolab.outputs.kube_client_certificate),
    base64encode(data.terraform_remote_state.argolab.outputs.kube_client_key),
    base64encode(data.terraform_remote_state.argolab.outputs.kube_cluster_ca_certificate),
  ]
}
