resource "vault_pki_secret_backend_role" "vault_pki_secret_backend_role_cert_manager" {
  backend          = vault_mount.pki.path
  name             = "cert-manager"
  ttl              = 3600
  max_ttl          = "259200"
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 2048
  allowed_domains  = ["${local.domain}", "svc.cluster.local"]
  allow_subdomains = true
  require_cn       = false
}

resource "vault_policy" "pki_cert_manager" {
  name   = "pki-cert-manager"
  policy = <<EOT
path "pki*"                        { capabilities = ["read", "list"] }
path "pki/roles/cert-manager"   { capabilities = ["create", "update"] }
path "pki/sign/cert-manager"    { capabilities = ["create", "update"] }
path "pki/issue/cert-manager"   { capabilities = ["create"] }
EOT
}

resource "vault_kubernetes_auth_backend_role" "this" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "cert-manager"
  bound_service_account_names      = ["vault-cert"]
  bound_service_account_namespaces = ["cert-manager"]
  token_ttl                        = 3600
  token_policies                   = ["pki-cert-manager"]
}
