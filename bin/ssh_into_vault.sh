#!/bin/bash
set -ex
VAULT_IP=$(ssh -tt -A -F ./vault/terraform/ssh.config bastion "curl -s http://127.0.0.1:8500/v1/agent/members | jq -M -r '[.[] | select(.Name | contains (\"tf-vault-elixir-vault\")) | .Addr][0]' | tac") 
ssh -tt -A -F ./vault/terraform/ssh.config bastion ssh -A ec2-user@$VAULT_IP 
