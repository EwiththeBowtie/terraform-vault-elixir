#!/bin/bash
set -ex
pushd ./vault/terraform/
terraform apply
popd
