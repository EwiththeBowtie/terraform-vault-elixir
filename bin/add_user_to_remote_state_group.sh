#!/bin/bash
set -e
if [[ $# -ne 1 ]]; then
  echo "Please supply an aws username"
  exit 1
fi
aws iam add-user-to-group --user-name "$1" --group-name TfRemoteStateGroup
