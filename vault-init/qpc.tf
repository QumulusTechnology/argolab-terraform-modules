resource "random_password" "qpc_postgres_password" {
  length           = 24
  special          = true
  override_special = "!@#%^&*()_-+={}[]"
}

resource "vault_azure_secret_backend_role" "qpc" {
  backend = vault_azure_secret_backend.this.path
  role    = "qpc-azure-access"
  ttl     = 1800
  max_ttl = 3600

  azure_roles {
    role_name = "Reader"
    scope     = "/subscriptions/${local.subscription_id}"
  }

  azure_roles {
    role_name = "Contributor"
    scope     = "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Storage/storageAccounts/qmlsqpclusters${local.environment_short_name}"
  }

  azure_roles {
    role_name = "Contributor"
    scope     = "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Storage/storageAccounts/qmlsqpcrsrc${local.environment_short_name}"
  }
}

resource "vault_policy" "qpc" {
  name = "qpc-database-azure-access"

  policy = <<EOT
path "${vault_azure_secret_backend.this.path}/creds/${vault_azure_secret_backend_role.qpc.role}" {
  capabilities = ["read"]
}
path "${vault_database_secrets_mount.db.path}/creds/${vault_database_secret_backend_role.qpc_postgres.name}" {
  capabilities = ["read"]
}
EOT
}

#TODO: Consider creating the database within argocd

resource "azurerm_postgresql_flexible_server" "qpc" {
  name                          = "qpcpostgresserver"
  resource_group_name           = local.resource_group_name
  location                      = local.resource_group_location
  version                       = "14"
  administrator_login           = "psqladmin"
  administrator_password        = random_password.qpc_postgres_password.result

  storage_mb = 32768

  sku_name = "B_Standard_B1ms"
  zone = 2

}

resource "azurerm_postgresql_flexible_server_database" "qpc" {
  name      = "qpcpostgresdb"
  server_id = azurerm_postgresql_flexible_server.qpc.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "qpc" {
  name             = "allow-all"
  server_id        = azurerm_postgresql_flexible_server.qpc.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

resource "vault_database_secret_backend_role" "qpc_postgres" {
  backend = vault_database_secrets_mount.db.path
  name    = "qpc"
  db_name = "qpc_postgres"
  default_ttl = 31536000
  max_ttl     = 31536000
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' INHERIT;",
    "GRANT qpc TO \"{{name}}\";",
    "GRANT ALL ON DATABASE QPC TO QPC;",
    "GRANT ALL PRIVILEGES ON SCHEMA PUBLIC TO QPC;",
    "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA PUBLIC TO QPC;",
    "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA PUBLIC TO QPC;",
    "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA PUBLIC TO QPC;",
  ]
}

resource "vault_kubernetes_auth_backend_role" "qpc" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "qpc-database-azure-access"
  bound_service_account_names      = ["qpc-database-azure-credentials"]
  bound_service_account_namespaces = ["qpc"]
  token_ttl                        = 3600
  token_policies                   = ["qpc-database-azure-access"]
}
