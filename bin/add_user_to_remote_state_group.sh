#!/bin/bash
set -ev
aws iam add-user-to-group --user-name "$1" --group-name TfRemoteStateGroup
