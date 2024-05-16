
resource "vault_mount" "pki_root" {
  # provider              = vault.parent
  count                 = local.is_prod_or_dev == true ? 1 : 0
  path                  = "pki-root"
  type                  = "pki"
  max_lease_ttl_seconds = 315360000
}

resource "vault_pki_secret_backend_crl_config" "crl_config_root" {
  # provider = vault.parent
  count    = local.is_prod_or_dev == true ? 1 : 0
  backend  = vault_mount.pki_root[0].path
  expiry   = "72h"
  disable  = false
}

resource "vault_pki_secret_backend_config_urls" "config_urls_root" {
  # provider                = vault.parent
  count                   = local.is_prod_or_dev == true ? 1 : 0
  backend                 = vault_mount.pki_root[0].path
  issuing_certificates    = ["https://vault.${local.domain}/v1/pki-root/ca"]
  crl_distribution_points = ["https://vault.${local.domain}/v1/pki-root/crl"]
}

resource "vault_pki_secret_backend_root_cert" "ca_root" {
  # provider             = vault.parent
  count                = local.is_prod_or_dev == true ? 1 : 0
  backend              = vault_mount.pki_root[0].path
  type                 = "internal"
  common_name          = "Qumulus ${local.environment} Root CA"
  ttl                  = "315360000"
  format               = "pem"
  private_key_format   = "der"
  key_type             = "rsa"
  key_bits             = 4096
  exclude_cn_from_sans = true
  organization         = "Qumulus Technlogy Ltd"
  depends_on = [
    vault_pki_secret_backend_crl_config.crl_config_root[0],
    vault_pki_secret_backend_config_urls.config_urls_root[0]
  ]
}

resource "vault_mount" "pki" {
  path = "pki"
  type = "pki"
}

#Intermediate
resource "vault_pki_secret_backend_intermediate_cert_request" "this" {
  backend              = vault_mount.pki.path
  type                 = "internal"
  common_name          = "Qumulus ${local.environment} Intermediate CA"
  format               = "pem"
  private_key_format   = "der"
  key_type             = "rsa"
  key_bits             = 4096
  exclude_cn_from_sans = true
  organization         = "Qumulus Technlogy Ltd"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "this" {
  # provider             = vault.parent
  backend              = "pki-root"
  ttl                  = "315360000"
  csr                  = vault_pki_secret_backend_intermediate_cert_request.this.csr
  common_name          = "Qumulus ${local.environment} Intermediate CA"
  exclude_cn_from_sans = true
  ou                   = local.domain
  organization         = "Qumulus Technlogy Ltd"
  country              = "GB"
  locality             = "Manchester"
  province             = "Greater Manchester"
  revoke               = true
  depends_on = [
    vault_pki_secret_backend_root_cert.ca_root[0],
  ]
}

resource "vault_pki_secret_backend_crl_config" "crl_config" {
  backend = vault_mount.pki.path
  expiry  = "72h"
  disable = false
}

resource "vault_pki_secret_backend_config_urls" "config_urls" {
  backend                 = vault_mount.pki.path
  issuing_certificates    = ["https://vault.${local.domain}/v1/pki/ca"]
  crl_distribution_points = ["https://vault.${local.domain}/v1/pki/crl"]
}

resource "vault_pki_secret_backend_intermediate_set_signed" "this" {
  backend     = vault_mount.pki.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.this.certificate

  provisioner "local-exec" {
    command = "${path.module}/scripts/delete_cluster_issuer.sh ${data.terraform_remote_state.argolab.outputs.kube_host} ${base64encode(data.terraform_remote_state.argolab.outputs.kube_client_certificate)} ${base64encode(data.terraform_remote_state.argolab.outputs.kube_client_key)} ${base64encode(data.terraform_remote_state.argolab.outputs.kube_cluster_ca_certificate)}"
  }
}
