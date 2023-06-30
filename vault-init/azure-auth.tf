module "vault_service_principal" {

  source = "github.com/QumulusTechnology/terraform-azure-enterprise-application.git?ref=v1.0.13"

  name                          = "Vault${local.environment}"
  display_name                  = "Vault${local.environment}"
  api_name                      = "Vault${local.environment}.${local.domain}"
  enterprise                    = "true"
  gallery                       = "true"
  app_role_assignment_required  = "true"
  optional_claims_access_tokens = ["groups", "upn", "email"]
  optional_claims_id_tokens     = ["groups", "upn", "email"]
  optional_claims_saml2_tokens  = ["groups", "upn", "email"]
  group_membership_claims       = ["All"]
  app_roles = [{
    "role" : "azuread-sso"
    "groups_to_assign" : ["Administrators", "Developers", "Engineering", "Vault Admins", "DevOps"]
    "users_to_assign" : []
  }]

  application_role_assignments = [{
    "application" : "MicrosoftGraph",
    "application_roles" : [
      "User.Read.All",
      "Application.Read.All",
      "Directory.Read.All",
      "Group.Read.All",
      "GroupMember.Read.All",
    ],
    "delegated_roles" : [
      "Application.Read.All",
      "Directory.Read.All",
      "Group.Read.All",
      "GroupMember.Read.All",
      "profile"
    ] }, {
    "application" : "AzureActiveDirectoryGraph",
    "application_roles" : [
    ],
    "delegated_roles" : [
      "Group.Read.All",
      "User.Read",
  ] }]
  redirect_uris = ["http://localhost:8250/oidc/callback", "https://vault.${local.domain}/ui/vault/auth/oidc/oidc/callback"]
}

resource "vault_auth_backend" "this" {
  type = "azure"
}

resource "vault_azure_auth_backend_config" "this" {
  backend       = vault_auth_backend.this.path
  tenant_id     = module.vault_service_principal.tenant_id
  client_id     = module.vault_service_principal.client_id
  client_secret = module.vault_service_principal.service_principal_password
  resource      = local.vault_url
}

resource "vault_jwt_auth_backend" "this" {
  description  = "Azure Authentication"
  path         = "oidc"
  type         = "oidc"
  default_role = "azuread-sso"

  oidc_discovery_url = "https://login.microsoftonline.com/${module.vault_service_principal.tenant_id}/v2.0"
  oidc_client_id     = module.vault_service_principal.client_id
  oidc_client_secret = module.vault_service_principal.service_principal_password
}

resource "vault_jwt_auth_backend_role" "azuread-sso" {
  backend        = vault_jwt_auth_backend.this.path
  role_name      = "azuread-sso"
  user_claim     = "email"
  role_type      = "oidc"
  token_policies = ["default"]
  allowed_redirect_uris = [
    "http://localhost:8250/oidc/callback",
    "${local.vault_url}/ui/vault/auth/oidc/oidc/callback",
    "http://localhost:8200/ui/vault/auth/oidc/oidc/callback"
  ]
  groups_claim = "groups"
  oidc_scopes  = ["https://graph.microsoft.com/.default", "profile", "email"]

  verbose_oidc_logging = false
}
