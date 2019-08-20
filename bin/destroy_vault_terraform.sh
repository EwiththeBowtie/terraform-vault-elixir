#!/bin/bash
set -ex
pushd ./vault/terraform/
terraform destroy
popd
