module "vault_service_principal_secret_engine" {

  source = "github.com/QumulusTechnology/terraform-azure-enterprise-application.git?ref=v1.0.13"

  name                         = "Vault${var.environment}AzureCredentialsEngine"
  display_name                 = "Vault${var.environment}AzureCredentialsEngine"
  api_name                     = "Vault${var.environment}AzureCredentialsEngine.${var.domain}"
  enterprise                   = "false"
  gallery                      = "false"
  app_role_assignment_required = "true"

  application_role_assignments = [{
    "application" : "MicrosoftGraph",
    "application_roles" : [
      "User.Read.All",
      "Application.Read.All",
      "Application.ReadWrite.All",
      "Application.ReadWrite.OwnedBy",
      "Directory.Read.All",
      "Directory.ReadWrite.All",
      "Group.Read.All",
      "Group.ReadWrite.All",
      "GroupMember.Read.All",
      "GroupMember.ReadWrite.All"
    ],
    "delegated_roles" : [
      "Application.Read.All",
      "Application.ReadWrite.All",
      "Directory.Read.All",
      "Directory.ReadWrite.All",
      "Directory.AccessAsUser.All",
      "Group.Read.All",
      "Group.ReadWrite.All",
      "GroupMember.Read.All",
      "GroupMember.ReadWrite.All",
      "profile"
    ] }, {
    "application" : "AzureActiveDirectoryGraph",
    "application_roles" : [
      "Application.ReadWrite.All",
      "Directory.ReadWrite.All"
    ],
    "delegated_roles" : [
      "Group.ReadWrite.All",
      "User.Read",
  ] }]
}

resource "azurerm_role_assignment" "vault_service_principal_secret_engine_subscription_role_assignment" {
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Owner"
  principal_id         = module.vault_service_principal_secret_engine.service_principal_object_id
}

resource "vault_azure_secret_backend" "this" {
  use_microsoft_graph_api = true
  path                    = "azure"
  subscription_id         = var.subscription_id
  tenant_id               = var.tenant_id
  client_id               = module.vault_service_principal_secret_engine.client_id
  client_secret           = module.vault_service_principal_secret_engine.service_principal_password
  environment             = "AzurePublicCloud"
}

resource "vault_azure_secret_backend_role" "this" {
  backend = vault_azure_secret_backend.this.path
  role    = "azure-admin-role"
  ttl     = 1800
  max_ttl = 3600

  azure_roles {
    role_name = "Owner"
    scope     = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"
  }
  depends_on = [
    azurerm_role_assignment.vault_service_principal_secret_engine_subscription_role_assignment
  ]
}
