variable "global_storage_account_name" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "terraform_state_backend_key" {
  type = string
}

variable "vault_token" {
  type = string
}

variable "vault_init_response" {
  type = string
}

variable "cloud_portal_domain_prod" {
  type    = string
  default = "cloudportal.app"
}

variable "cloud_portal_domain_dev" {
  type    = string
  default = "cloudportal.xyz"
}
