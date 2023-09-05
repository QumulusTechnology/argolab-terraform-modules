resource "random_password" "vault_qpc_password" {
  length           = 24
  special          = true
  override_special = "!@#%^&*()_-+={}[]"
}

resource "postgresql_role" "vault_qpc_role" {
  provider         = postgresql.qpc

  name             = "qpc"
  login            = true
  create_role      = true
  superuser        = true
  connection_limit = 5
  password         = random_password.vault_qpc_password.result
}

resource "postgresql_database" "qpc_db" {
  provider         = postgresql.qpc

  name       = "qpc"
  owner      = "psqladmin"
  lc_collate = "en_US.utf8"
  lc_ctype   = "en_US.utf8"
  encoding   = "UTF8"
}

resource "postgresql_default_privileges" "vault_qpc_priv_schema" {
  provider         = postgresql.qpc

  database    = resource.postgresql_database.qpc_db.name
  owner       = "psqlqdmin"
  role        = resource.postgresql_role.vault_qpc_role.name
  schema      = "public"
  object_type = "table"
  privileges  = ["ALL"]
  depends_on  = [postgresql_database.qpc_db, postgresql_role.vault_qpc_role]
}

resource "postgresql_default_privileges" "vault_qpc_priv_sequence" {
  provider         = postgresql.qpc

  database    = resource.postgresql_database.qpc_db.name
  owner       = "psqladmin"
  role        = resource.postgresql_role.vault_qpc_role.name
  schema      = "public"
  object_type = "sequence"
  privileges  = ["ALL"]
  depends_on  = [postgresql_database.qpc_db, postgresql_role.vault_qpc_role]
}

resource "postgresql_default_privileges" "vault_qpc_priv_table" {
  provider         = postgresql.qpc

  database    = resource.postgresql_database.qpc_db.name
  owner       = "psqladmin"
  role        = resource.postgresql_role.vault_qpc_role.name
  schema      = "public"
  object_type = "table"
  privileges  = ["ALL"]
  depends_on  = [postgresql_database.qpc_db, postgresql_role.vault_qpc_role]
}

resource "postgresql_default_privileges" "vault_qpc_priv_function" {
  provider         = postgresql.qpc

  database    = resource.postgresql_database.qpc_db.name
  owner       = "psqladmin"
  role        = resource.postgresql_role.vault_qpc_role.name
  schema      = "public"
  object_type = "function"
  privileges  = ["ALL"]
  depends_on  = [postgresql_database.qpc_db, postgresql_role.vault_qpc_role]
}

