# terraform-vault-elixir
## Prerequisits 
  * AWS CLI
  * Terraform 0.12
  * An AWS account
  
## Getting Started
### Create Terraform Remote State (S3 non-locking)
`./bin/create_remote_state_stack.sh`
### Add user to remote state group
`./bin/add_user_to_remote_state_group.sh <AWS_USERNAME>`
## Creating Vault
`./bin/apply_vault_terraform.sh` 
### Auto unseal with AWS KMS
#### Log in to bastion
`ssh-add <tf-vault-elixir-override-<xxxxxxx>.key.pem>`

`ssh -A -i <generated pem key> ec2-user@<bastion-ip>`
#### Log into vault server (pre unseal)
`ssh -A ec2-user@$(curl http://127.0.0.1:8500/v1/agent/members | jq -M -r \
      '[.[] | select(.Name | contains ("tf-vault-elixir-vault")) | .Addr][0]')`
#### Unseal vault
`vault operator init -recovery-shares=1 -recovery-threshold=1`
 
## Tips and Tricks
### Local Port Forwarding for Vault
#### Add ssh config
``` 
Host bastion
  Hostname 34.219.188.84 
  User ec2-user
  IdentityFile  ~/dev/tf-vault-elixir/tf-vault-elixir-override-89cd452a.key.pem

Host vault.service.consul 
  IdentityFile  ~/dev/tf-vault-elixir/tf-vault-elixir-override-89cd452a.key.pem
  User ec2-user
  ProxyCommand ssh -W %h:%p  ec2-user@bastion
```
#### Start local port fowarding
`ssh -fCNL 8200:localhost:8200  ec2-user@vault.service.consul`
