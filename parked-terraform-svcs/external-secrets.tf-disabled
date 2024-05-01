#Long TTL until re resolve multi sources issue on ArgoLab
resource "vault_azure_secret_backend_role" "external-secrets" {
  backend = vault_azure_secret_backend.this.path
  role    = "external-secrets-azure-access"
  ttl     = "31536000"
  max_ttl = "31536000"

  azure_roles {
    role_name = "Key Vault Reader"
    scope     = data.azurerm_key_vault.argo.id
  }
  azure_roles {
    role_name = "Key Vault Secrets Officer"
    scope     = data.azurerm_key_vault.argo.id
  }

  azure_roles {
    role_name = "Key Vault Reader"
    scope     = data.azurerm_key_vault.global.id
  }
  azure_roles {
    role_name = "Key Vault Secrets Officer"
    scope     = data.azurerm_key_vault.global.id
  }
}


resource "vault_policy" "external-secrets" {
  name = "external-secrets-azure-access"

  policy = <<EOT
path "${vault_azure_secret_backend.this.path}/creds/${vault_azure_secret_backend_role.external-secrets.role}" {
  capabilities = ["read"]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "external-secrets" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "external-secrets-azure-access"
  bound_service_account_names      = ["external-secrets-azure-credentials"]
  bound_service_account_namespaces = ["external-secrets"]
  token_ttl                        = 31536000
  token_policies                   = ["external-secrets-azure-access"]
}
