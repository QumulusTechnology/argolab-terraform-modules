data "terraform_remote_state" "argolab" {
  backend = "azurerm"
  config = {
    resource_group_name  = "global"
    storage_account_name = var.storage_account_name
    container_name       = "tfstate"
    key                  = "${var.branch_clean}/argolab"
    subscription_id      = var.subscription_id
    tenant_id            = var.tenant_id
  }
}
