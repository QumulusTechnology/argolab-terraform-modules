#Not supported by crossplane
resource "elasticstack_elasticsearch_security_role" "vault_management_role" {
  name    = "vault-management-role"
  cluster = ["manage_security"]
}

resource "random_password" "vault_elasticsearch_password" {
  length  = 36
  special = false
}

resource "elasticstack_elasticsearch_security_user" "vault_user" {
  username = "vault-user"
  password = random_password.vault_elasticsearch_password.result
  roles    = [elasticstack_elasticsearch_security_role.vault_management_role.name]
}
