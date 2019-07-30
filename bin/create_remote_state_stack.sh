#!/bin/bash
aws cloudformation create-stack --stack-name tf-vault-elixir-remote-state --template-body file://./remote-state.yml --profile default

