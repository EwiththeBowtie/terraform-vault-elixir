#!/bin/bash
set -ex
pushd ./vault/vault-consul-ami/
packer build ./vault-consul.json
popd
