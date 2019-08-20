# terraform-vault-elixir
## Prerequisits 
  * [AWS CLI](https://formulae.brew.sh/formula/awscli)
  * [Terraform 0.11](https://formulae.brew.sh/formula/terraform@0.11)
  * [Packer](https://formulae.brew.sh/formula/packer)
  * An AWS account
  
## Getting Started
### Create Terraform Remote State (S3 non-locking)
`./bin/create_remote_state_stack.sh`
### Add user to remote state group
`./bin/add_user_to_remote_state_group.sh <AWS_USERNAME>`
### Build Vault Consul AMI (Packer)
`./bin/build_vault_ami.sh`
## Creating Vault
`./bin/apply_vault_terraform.sh` 
### Setup auto unseal with AWS KMS (required)
#### SSH into Vault
`./bin/ssh_into_vault.sh`
#### Unseal vault
`vault operator init -recovery-shares=1 -recovery-threshold=1`
### Setup Vault Admin User
```
$ ./bin/enable_local_port_forwarding_for_vault.sh`
$ ./bin/apply_vault_setup_terraform.sh`
$ var.admin_password
$   Enter a value: <password>
$
$ var.admin_username
$   Enter a value: <username>

```
