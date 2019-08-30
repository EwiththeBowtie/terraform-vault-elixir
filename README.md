# terraform-vault-elixir
![](/images/aws_default_diagram.svg)
- [terraform-vault-elixir](#terraform-vault-elixir)
  * [Purpose](#purpose)
  * [Development Process and Principles](#development-process-and-principles)
  * [Sources](#sources)
  * [Prerequisits](#prerequisits)
  * [Getting Started](#getting-started)
    + [Create Terraform Remote State (S3 non-locking)](#create-terraform-remote-state-s3-non-locking)
    + [Add user to remote state group](#add-user-to-remote-state-group)
    + [Build Vault Consul AMI (Packer)](#build-vault-consul-ami-packer)
  * [Creating Vault](#creating-vault)
    + [Setup auto unseal with AWS KMS (required)](#setup-auto-unseal-with-aws-kms-required)
      - [SSH into Vault](#ssh-into-vault)
      - [Unseal vault](#unseal-vault)
    + [Setup Vault Admin User](#setup-vault-admin-user)
## Purpose
The purpose of terraform-vault-elixir is to quickly and easily set up Vault and Consul for an Elixir application in AWS following best practices.  The terraform-vault-elixir set up includes:
* Creating a secure Terraform backend
* Creating a private cert
* Creating an Amazon Linux 2 AMI
* Instantiating EC2 instances for a bastion, Vault, and Consul
* Setting up auto unsealing Vault with a KMS Key
* Creating an easy way to manage Vault Users with Terraform
* TODO: Create an Elixir Cluster
* TODO: Automated testing and build
* TODO: Vault managed database passwords example for Elixir Pheonix Application
Bash scripts in the bin folder of the project document every step of the process.
## Development Process and Principles
This project follows two core principles:
* Impermanence
* Reproducibility

Impermanence is a priority because we want our servers to be cattle, not pets. We should be able to create, scale, or destroy each piece of our infrastructure at any time for whatever reason.  Eliminating a development environment at any time helps us keep down costs. In production, being able to add or remove servers based on load is critical.

Reproducibility is a priority because it is a challenge to find complete infrastructure guides demonstrating how to glue all the pieces together.  By starting our infrastructure from scratch every day, we can ensure some degree that someone trying this repo will be able to get up and to run.

We practice the principles of Impermanence and Reproducibility by creating our development infrastructure from scratch every morning and destroying it every night.  To support this, every command you will need to run is documented in a shell script.
## Sources

This repo heavily borrows from Hashicorps excellent Vault Best Practices guide: https://github.com/hashicorp/vault-guides/tree/master/operations/provision-vault/best-practices/terraform-aws

I also highly recommend this webinar by Becca Petrin from Hashicorp: https://www.youtube.com/watch?v=fOybhcbuxJ0 

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

Be sure to save the Root Token! We'll burn it later once we've set up a Vault admin user.

### Setup Vault Admin User
```
$ ./bin/enable_local_port_forwarding_for_vault.sh`
$ 
$ export VAULT_ADDR=https://127.0.0.1:8200
$ export VAULT_TOKEN=<VALID_VAULT_TOKEN>
$ export VAULT_SKIP_VERIFY=true 
$
$ ./bin/apply_vault_setup_terraform.sh`
$ 
$ var.admin_password
$   Enter a value: <password>
$
$ var.admin_username
$   Enter a value: <username>
```
