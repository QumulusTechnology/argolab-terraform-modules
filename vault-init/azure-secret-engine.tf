

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

