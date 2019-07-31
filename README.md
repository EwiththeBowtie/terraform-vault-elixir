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
