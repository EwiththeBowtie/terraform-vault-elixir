terraform {
  backend "s3" {
    bucket = "tf-vault-elixir-remote-state"
    key    = "vault/vault_setup/terraform.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
}

provider "vault" {
  /*
   It is strongly recommended to configure this provider through the
   environment variable, so that each user can have
   separate credentials set in the environment.

	$ export VAULT_ADDR=https://127.0.0.1:8200
	$ export VAULT_TOKEN=<VALID_VAULT_TOKEN>
	$ export VAULT_SKIP_VERIFY=true 
	 TODO: Set up vaild cert locally
	*/
}

resource "vault_auth_backend" "aws" {
  type = "aws"
}

data "local_file" "admin_policy" {
  filename = "${path.module}/vault_policies/admin.hcl"
}

resource "vault_policy" "admin" {
  name   = "admin"
  policy = "${data.local_file.admin_policy.content}"
}

resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

resource "vault_generic_endpoint" "admin_user" {
  depends_on           = ["vault_auth_backend.userpass"]
  path                 = "auth/userpass/users/${var.admin_username}"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["admin"],
  "password": "${var.admin_password}"
}
EOT
}
