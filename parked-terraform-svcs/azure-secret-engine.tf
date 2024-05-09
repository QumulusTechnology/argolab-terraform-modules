

# resource "vault_azure_secret_backend" "this" {
#   use_microsoft_graph_api = true
#   path                    = "azure"
#   subscription_id         = local.subscription_id
#   tenant_id               = local.tenant_id
#   client_id               = data.terraform_remote_state.argolab.outputs.vault_secret_engine_client_id
#   client_secret           = data.terraform_remote_state.argolab.outputs.vault_secret_engine_client_secret
#   environment             = "AzurePublicCloud"

# }

# resource "vault_azure_secret_backend_role" "this" {
#   backend = vault_azure_secret_backend.this.path
#   role    = "azure-admin-role"
#   ttl     = "31536000"
#   max_ttl = "31536000"

#   azure_roles {
#     role_name = "Owner"
#     scope     = "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}"
#   }
# }
