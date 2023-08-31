locals {
  environment             = data.terraform_remote_state.argolab.outputs.environment
  environment_short_name  = data.terraform_remote_state.argolab.outputs.environment_short_name
  full_environmment_name  = data.terraform_remote_state.argolab.outputs.full_environmment_name
  subscription_id         = data.terraform_remote_state.argolab.outputs.subscription_id
  tenant_id               = data.terraform_remote_state.argolab.outputs.tenant_id
  parent_domain           = data.terraform_remote_state.argolab.outputs.parent_domain
  domain                  = data.terraform_remote_state.argolab.outputs.domain
  keyvault_name_global    = data.terraform_remote_state.argolab.outputs.keyvault_name_global
  keyvault_name_argo      = data.terraform_remote_state.argolab.outputs.keyvault_name_argo
  resource_group_name     = data.terraform_remote_state.argolab.outputs.resource_group_name
  resource_group_location = data.terraform_remote_state.argolab.outputs.resource_group_location
  dns_resource_group      = data.terraform_remote_state.argolab.outputs.dns_resource_group
  vault_token             = data.kubernetes_secret.vault-token.data["token"]
  vault_url               = "https://vault.${local.domain}"

  is_prod_or_dev   = local.parent_domain == local.domain ? true : false
  domain_name_safe = replace(local.domain, ".", "-dot-")
}
