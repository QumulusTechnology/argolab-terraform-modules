resource "vault_azure_secret_backend_role" "velero" {
  backend = vault_azure_secret_backend.this.path
  role    = "velero-azure-access"
  ttl     = 18000
  max_ttl = 36000

  azure_roles {
    role_name = "Contributor"
    scope     = "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Storage/storageAccounts/qmlsvelero${local.environment_short_name}"
  }
  azure_roles {
    role_name = "Reader"
    scope     = "/subscriptions/${local.subscription_id}"
  }
}

resource "vault_policy" "velero" {
  name = "velero-azure-access"

  policy = <<EOT
path "${vault_azure_secret_backend.this.path}/creds/${vault_azure_secret_backend_role.velero.role}" {
  capabilities = ["read"]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "velero" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "velero-azure-access"
  bound_service_account_names      = ["velero-azure-credentials"]
  bound_service_account_namespaces = ["velero"]
  token_ttl                        = 3600
  token_policies                   = ["velero-azure-access"]
}