resource "random_password" "vault_qpc_password" {
  length           = 24
  special          = true
  override_special = "!@#%^&*()_-+={}[]"
}

resource "postgresql_role" "vault_qpc_role" {
  provider         = postgresql.qpc

  name             = "vaut-qpc-role"
  login            = true
  create_role      = true
  superuser        = true
  connection_limit = 5
  password         = random_password.vault_qpc_password.result
}

resource "postgresql_role" "qpc_role" {
  provider         = postgresql.qpc

  name             = "qpc"
  login            = false
  superuser        = false
  create_role      = false
  connection_limit = 20
}

resource "postgresql_database" "qpc" {
  provider         = postgresql.qpc

  name              = "qpc"
  owner             = postgresql_role.qpc_role.name
  template          = "template0"
  lc_collate        = "DEFAULT"
  connection_limit  = -1
  allow_connections = true
}

resource "vault_database_secret_backend_role" "qpc_postgres" {
  backend = vault_database_secrets_mount.db.path
  name    = "qpc"
  db_name = "qpc"
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
  revocation_statements = [
    "REASSIGN OWNED BY \"{{name}}\" TO qpc;",  
    "DROP ROLE \"{{name}}\";"
  ]    
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
    scope     = "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Storage/storageAccounts/qmlsqpcclusters${local.environment_short_name}"
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


resource "vault_kubernetes_auth_backend_role" "qpc" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "qpc-database-azure-access"
  bound_service_account_names      = ["qpc-azure-credentials", "qpc-database-credentials"]
  bound_service_account_namespaces = ["qpc"]
  token_ttl                        = 3600
  token_policies                   = ["qpc-database-azure-access"]
}
