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
	*/
}

resource "vault_auth_backend" "aws" {
  type = "aws"
}

data "local_file" "admin_policy" {
  filename = "${path.module}/vault_policies/admin.hcl"
}

resource "vault_policy" "vault_administrator" {
  name   = "vault-administrator"
  policy = "${data.local_file.admin_policy.content}"
}

resource "vault_github_auth_backend" "github" {
  organization = "${var.github_org}"
  max_ttl      = "24h"
}

resource "vault_github_team" "vault_admin" {
  backend        = "${vault_github_auth_backend.github.id}"
  team           = "${var.github_team}"
	policies = ["${vault_policy.vault_administrator.name}"]
	token_no_default_policy = "true"
}
