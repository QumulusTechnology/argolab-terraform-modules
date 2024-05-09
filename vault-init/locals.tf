locals {
  environment            = data.terraform_remote_state.argolab.outputs.environment
  environment_short_name = data.terraform_remote_state.argolab.outputs.environment_short_name
  full_environmment_name = data.terraform_remote_state.argolab.outputs.full_environmment_name
  subscription_id        = data.terraform_remote_state.argolab.outputs.subscription_id
  tenant_id              = data.terraform_remote_state.argolab.outputs.tenant_id
  parent_domain          = data.terraform_remote_state.argolab.outputs.parent_domain
  domain                 = data.terraform_remote_state.argolab.outputs.domain
  keyvault_name_global   = data.terraform_remote_state.argolab.outputs.keyvault_name_global
  keyvault_name_argo     = data.terraform_remote_state.argolab.outputs.keyvault_name_argo
  resource_group_name    = data.terraform_remote_state.argolab.outputs.resource_group_name
  dns_resource_group     = data.terraform_remote_state.argolab.outputs.dns_resource_group
  vault_url              = "https://vault.${local.domain}"
  cert_manager_allowed_domains_base  = [ local.domain, "svc.cluster.local"]
  cert_manager_allowed_domains = local.environment_short_name == "prod" ? concat(local.cert_manager_allowed_domains_base, [var.cloud_portal_domain_prod]) : local.environment_short_name == "dev" ? concat(local.cert_manager_allowed_domains_base, [var.cloud_portal_domain_dev]) : local.cert_manager_allowed_domains_base

  is_prod_or_dev   = local.parent_domain == local.domain ? true : false
  domain_name_safe = replace(local.domain, ".", "-dot-")
}
