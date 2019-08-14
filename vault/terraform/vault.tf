provider "vault" {
  # It is strongly recommended to configure this provider through the
  # environment variables described above, so that each user can have
  # separate credentials set in the environment.
  #
	# $ export VAULT_ADDR=https://127.0.0.1:8200
	# $ export VAULT_TOKEN=<VALID_VAULT_TOKEN>
	# $ export VAULT_SKIP_VERIFY=true 
	# TODO: Set up vaild cert locally
}  

resource "vault_auth_backend" "aws" {
  type = "aws"
} 

