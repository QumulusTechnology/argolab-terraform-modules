
resource "vault_database_secret_backend_role" "zabbix3_postgres" {
  backend     = vault_database_secrets_mount.db.path
  db_name     = "zabbix3"
  name        = "zabbix3"
  default_ttl = 31536000
  max_ttl     = 31536000
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' INHERIT;",
    "GRANT zabbix3 TO \"{{name}}\";",
    "GRANT ALL ON DATABASE zabbix3 TO zabbix3;",
    "GRANT ALL PRIVILEGES ON SCHEMA PUBLIC TO zabbix3;",
    "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA PUBLIC TO zabbix3;",
    "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA PUBLIC TO zabbix3;",
    "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA PUBLIC TO zabbix3;",
  ]
  revocation_statements = [
    "REASSIGN OWNED BY \"{{name}}\" TO zabbix3;",
    "DROP OWNED BY \"{{name}}\";"
  ]
}

resource "vault_policy" "zabbix3_database_access" {
  name   = "zabbix3-database-access"
  policy = <<EOT
path "database/creds/zabbix3" {
  capabilities = [ "read" ]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "zabbix3" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "zabbix3-database-access"
  bound_service_account_names      = ["zabbix3-database-credentials"]
  bound_service_account_namespaces = ["zabbix3"]
  token_ttl                        = 31536000
  token_policies                   = ["zabbix3-database-access"]
}
