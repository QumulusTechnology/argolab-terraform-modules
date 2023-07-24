#Long TTL until re resolve multi sources issue on ArgoLab
resource "vault_azure_secret_backend_role" "external-dns" {
  backend = vault_azure_secret_backend.this.path
  role    = "external-dns-azure-access"
  ttl     = "8760h"
  max_ttl = "8760h"

  azure_roles {
    role_name = "DNS Zone Contributor"
    scope     = "/subscriptions/${local.subscription_id}/resourceGroups/${local.dns_resource_group}/providers/Microsoft.Network/dnszones/${local.domain}"
  }
  azure_roles {
    role_name = "Reader"
    scope     = "/subscriptions/${local.subscription_id}/resourceGroups/${local.dns_resource_group}"
  }
}


resource "vault_policy" "external-dns" {
  name = "external-dns-azure-access"

  policy = <<EOT
path "${vault_azure_secret_backend.this.path}/creds/${vault_azure_secret_backend_role.external-dns.role}" {
  capabilities = ["read"]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "external-dns" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "external-dns-azure-access"
  bound_service_account_names      = ["external-dns-azure-credentials"]
  bound_service_account_namespaces = ["external-dns"]
  token_ttl                        = 3600
  token_policies                   = ["external-dns-azure-access"]
}
