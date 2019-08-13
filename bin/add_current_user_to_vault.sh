#!/bin/bash
set -ex

CURRENT_USER_ARN=$(aws sts get-caller-identity | jq --raw-output .Arn)

vault write -tls-skip-verify auth/aws/role/dev-role-iam auth_type=iam bound_iam_principal_arn=$CURRENT_USER_ARN policies=dev max_ttl=24h 
