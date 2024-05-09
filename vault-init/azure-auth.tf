resource "vault_auth_backend" "this" {
  type = "azure"
}

resource "vault_azure_auth_backend_config" "this" {
  backend       = vault_auth_backend.this.path
  tenant_id     = local.tenant_id
  client_id     = data.kubernetes_secret.azure-sso-credentials.data["ARM_CLIENT_ID"]
  client_secret = data.kubernetes_secret.azure-sso-credentials.data["ARM_CLIENT_SECRET"]
  resource      = "https://vault.${local.domain}"
}

resource "vault_jwt_auth_backend" "this" {
  description  = "Azure Authentication"
  path         = "oidc"
  type         = "oidc"
  default_role = "azuread-sso"

  oidc_discovery_url = "https://login.microsoftonline.com/${local.tenant_id}/v2.0"
  oidc_client_id     = data.kubernetes_secret.azure-sso-credentials.data["ARM_CLIENT_ID"]
  oidc_client_secret = data.kubernetes_secret.azure-sso-credentials.data["ARM_CLIENT_SECRET"]
}

resource "vault_jwt_auth_backend_role" "azuread-sso" {
  backend        = vault_jwt_auth_backend.this.path
  role_name      = "azuread-sso"
  user_claim     = "email"
  role_type      = "oidc"
  token_policies = ["default"]
  allowed_redirect_uris = [
    "http://localhost:8250/oidc/callback",
    "https://vault.${local.domain}/ui/vault/auth/oidc/oidc/callback",
    "http://localhost:8200/ui/vault/auth/oidc/oidc/callback"
  ]
  groups_claim = "groups"
  oidc_scopes  = ["https://graph.microsoft.com/.default", "profile", "email"]

  verbose_oidc_logging = false
}
