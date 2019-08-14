#!/bin/bash
set -ex
ssh -tt -A -F ./vault/terraform/ssh.config bastion 
