#!/bin/bash
aws cloudformation describe-stack-events --stack-name tf-vault-elixir-remote-state --output text
