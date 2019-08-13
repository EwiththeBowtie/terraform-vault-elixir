vault policy write -tls-skip-verify dev-policy -<<EOF
path "aws/creds/dev-role" {
  capabilities = ["read"]
}
EOF
