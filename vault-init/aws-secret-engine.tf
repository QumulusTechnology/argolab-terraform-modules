resource "vault_aws_secret_backend" "aws" {
  access_key = data.terraform_remote_state.argolab.outputs.vault_iam_user_id
  secret_key = data.terraform_remote_state.argolab.outputs.vault_iam_user_secret
}
