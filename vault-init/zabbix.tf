
resource "vault_database_secret_backend_role" "zabbix_postgres" {
  backend     = vault_database_secrets_mount.db.path
  db_name     = "zabbix"
  name        = "zabbix"
  default_ttl = 31536000
  max_ttl     = 31536000
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' INHERIT;",
    "GRANT zabbix TO \"{{name}}\";",
    "GRANT ALL ON DATABASE zabbix TO zabbix;",
    "GRANT ALL PRIVILEGES ON SCHEMA PUBLIC TO zabbix;",
    "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA PUBLIC TO zabbix;",
    "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA PUBLIC TO zabbix;",
    "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA PUBLIC TO zabbix;",
  ]
  revocation_statements = [
    "REASSIGN OWNED BY \"{{name}}\" TO zabbix;",
    "DROP OWNED BY \"{{name}}\";"
  ]
}

resource "vault_policy" "zabbix_database_access" {
  name   = "zabbix-database-access"
  policy = <<EOT
path "database/creds/zabbix" {
  capabilities = [ "read" ]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "zabbix" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "zabbix-database-access"
  bound_service_account_names      = ["zabbix-database-credentials"]
  bound_service_account_namespaces = ["zabbix"]
  token_ttl                        = 31536000
  token_policies                   = ["zabbix-database-access"]
}
