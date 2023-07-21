

resource "vault_azure_secret_backend" "this" {
  use_microsoft_graph_api = true
  path                    = "azure"
  subscription_id         = local.subscription_id
  tenant_id               = local.tenant_id
  client_id               = data.kubernetes_secret.azure-session-credentials.data["ARM_CLIENT_ID"]
  client_secret           = data.kubernetes_secret.azure-session-credentials.data["ARM_CLIENT_SECRET"]
  environment             = "AzurePublicCloud"
}

resource "vault_azure_secret_backend_role" "this" {
  backend = vault_azure_secret_backend.this.path
  role    = "azure-admin-role"
  ttl     = 1800
  max_ttl = 3600

  azure_roles {
    role_name = "Owner"
    scope     = "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}"
  }
}

resource "vault_azure_secret_backend_role" "velero" {
  backend = vault_azure_secret_backend.this.path
  role    = "velero-role"
  ttl     = 18000
  max_ttl = 36000

  azure_roles {
    role_name = "Contributor"
    scope     = "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Storage/storageAccounts/qmlsvelero${local.environment_short_name}"
  }
}

resource "vault_policy" "velero" {
  name = "velero-policy"

  policy = <<EOT
path "${vault_azure_secret_backend.this.path}/creds/${vault_azure_secret_backend_role.velero.role}" {
  capabilities = ["read"]
}
EOT
}
