variable "branch" {
  type = string
}

variable "environment" {
  type = string
}

variable "vault_parent_token" {
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
