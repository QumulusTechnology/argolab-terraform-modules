
# This synchronises the groups from Azure AD into Vault
module "vault_azure_ad_groups" {
  source           = "git@github.com:QumulusTechnology/terraform-vault-azuread-groups.git?ref=v1.0.2"
  mount_accessor = vault_jwt_auth_backend.this.accessor
  security_enabled = true
}

# This synchronises the users from Azure AD into Vault
module "vault_azure_ad_users" {
  source      = "git@github.com:QumulusTechnology/terraform-vault-azuread-users.git?ref=v1.0.2"
  mount_accessor = vault_jwt_auth_backend.this.accessor
}

resource "vault_identity_group_policies" "vault_admins" {
  policies = [
    vault_policy.root_access.name
  ]
  exclusive = false
  group_id  = data.vault_identity_group.vault_admins.group_id
}

resource "vault_identity_group_policies" "engineers" {
  policies = [
    vault_policy.super_admin.name
  ]
  exclusive = false
  group_id  = data.vault_identity_group.engineering.group_id
}

resource "vault_identity_group_policies" "devops" {
  policies = [
    vault_policy.super_admin.name
  ]
  exclusive = false
  group_id  = data.vault_identity_group.devops.group_id
}
