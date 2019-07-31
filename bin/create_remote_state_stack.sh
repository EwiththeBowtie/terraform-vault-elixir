#!/bin/bash
aws cloudformation create-stack --stack-name tf-vault-elixir-remote-state --template-body file://./cloudformation/remote-state.yml --profile default --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM
