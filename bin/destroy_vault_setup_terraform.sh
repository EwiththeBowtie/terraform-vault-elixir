#!/bin/bash
set -ex
pushd ./vault/terraform/vault_setup/
terraform destroy
popd
