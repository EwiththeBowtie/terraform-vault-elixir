#!/bin/bash
set -ex
ssh -F ./vault/terraform/ssh.config -fCNL 8200:localhost:8200 ec2-user@vault.service.consul
