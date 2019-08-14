#!/bin/bash
set -ex

ssh -F ./vault/terraform/ssh.config bastion
