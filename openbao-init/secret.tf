resource "vault_mount" "secret" {
  path        = "secret"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_backend_v2" "secret" {
  mount                = vault_mount.secret.path
  max_versions         = 10
  delete_version_after = 12600
  cas_required         = true
}

resource "vault_policy" "secret-access" {
  name   = "secret-access"
  policy = <<EOT
path "secret/*" {
  capabilities = [ "create", "read", "update", "delete", "list"]
}
EOT
}
