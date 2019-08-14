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

data "aws_caller_identity" "current" {}

resource "vault_auth_backend" "aws" {
  type = "aws"
}

data "local_file" "admin_policy" {
    filename = "${path.module}/vault_policies/admin.hcl"
}

resource "vault_policy" "admin" {
	name = "admin"
  policy = "${data.local_file.admin_policy.content}"
}

resource "vault_aws_auth_backend_role" "admin" {
  backend                         = "${vault_auth_backend.aws.path}"
  role                            = "admin"
  auth_type                       = "iam"
  bound_iam_principal_arns             = ["${data.aws_caller_identity.current.arn}"]
  token_ttl                       = 60
  token_max_ttl                   = 120
  token_policies                  = ["admin"]
}	
