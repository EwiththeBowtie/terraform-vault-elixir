output "zREADME" {
  value = <<README

Your "${var.name}" AWS Vault cluster has been
successfully provisioned!

${module.network_aws.zREADME}To force the generation of a new key, the private key instance can be "tainted"
using the below command.

  $ terraform taint -module=ssh_keypair_aws_override.tls_private_key \
      tls_private_key.key
${var.download_certs ?
"\n${module.root_tls_self_signed_ca.zREADME}
${module.leaf_tls_self_signed_cert.zREADME}
# ------------------------------------------------------------------------------
# Local HTTP API Requests
# ------------------------------------------------------------------------------

If you're making HTTPS API requests outside the Bastion (locally), set
the below env vars.

The `vault_public` and `consul_public` variables must be set to true for
requests to work.

`vault_public`: ${var.vault_public}
`consul_public`: ${var.consul_public}

  $ export VAULT_CACERT=${path.cwd}/${module.leaf_tls_self_signed_cert.ca_cert_filename}
  $ export VAULT_CLIENT_CERT=${path.cwd}/${module.leaf_tls_self_signed_cert.leaf_cert_filename}
  $ export VAULT_CLIENT_KEY=${path.cwd}/${module.leaf_tls_self_signed_cert.leaf_private_key_filename}

  $ export CONSUL_CACERT=${path.cwd}/${module.leaf_tls_self_signed_cert.ca_cert_filename}
  $ export CONSUL_CLIENT_CERT=${path.cwd}/${module.leaf_tls_self_signed_cert.leaf_cert_filename}
  $ export CONSUL_CLIENT_KEY=${path.cwd}/${module.leaf_tls_self_signed_cert.leaf_private_key_filename}\n" : ""}
# ------------------------------------------------------------------------------
# Vault Best Practices
# ------------------------------------------------------------------------------

Once on the Bastion host, you can use Consul's DNS functionality to seamlessly
SSH into other Consul or Vault nodes if they exist.

  $ ssh -A ${module.consul_aws.consul_username}@consul.service.consul

  # Vault must be initialized & unsealed for this command to work
  $ ssh -A ${module.vault_aws.vault_username}@vault.service.consul

# ------------------------------------------------------------------------------
# Add SSH key to Configure Vault!!! 
# ------------------------------------------------------------------------------

  $ ssh-add ${path.module}/${module.ssh_keypair_aws_override.private_key_filename} 

# ------------------------------------------------------------------------------
# Initialize Vault (Auto-Unseal)
# ------------------------------------------------------------------------------
  $ ./bin/ssh_into_vault.sh
  $ vault operator init -recovery-shares=1 -recovery-threshold=1
  # NOTE THE ROOT TOKEN, YOU'LL NEED IT (FOR NOW, we'll burn it later.  In the fires of mount Doom.)

# ------------------------------------------------------------------------------
# Set Up Vault
# ------------------------------------------------------------------------------
		
  $ ./bin/enable_local_port_forwarding_for_vault.sh
  $ 
  $ export VAULT_ADDR=https://127.0.0.1:8200
  $ export VAULT_TOKEN=<VALID_VAULT_TOKEN>
  $ export VAULT_SKIP_VERIFY=true 
  $
  $ ./bin/apply_vault_setup_terraform.sh`
  $ 
	$ var.admin_password
  $   Enter a value: <password>
  $
  $ var.admin_username
  $   Enter a value: <username>

README
}

output "vpc_cidr" {
  value = "${module.network_aws.vpc_cidr}"
}

output "vpc_id" {
  value = "${module.network_aws.vpc_id}"
}

output "subnet_public_ids" {
  value = "${module.network_aws.subnet_public_ids}"
}

output "subnet_private_ids" {
  value = "${module.network_aws.subnet_private_ids}"
}

output "bastion_security_group" {
  value = "${module.network_aws.bastion_security_group}"
}

output "bastion_ips_public" {
  value = "${module.network_aws.bastion_ips_public}"
}

output "bastion_username" {
  value = "${module.network_aws.bastion_username}"
}

output "private_key_name" {
  value = "${module.ssh_keypair_aws_override.private_key_name}"
}

output "private_key_filename" {
  value = "${module.ssh_keypair_aws_override.private_key_filename}"
}

output "private_key_pem" {
  value = "${module.ssh_keypair_aws_override.private_key_pem}"
}

output "public_key_pem" {
  value = "${module.ssh_keypair_aws_override.public_key_pem}"
}

output "public_key_openssh" {
  value = "${module.ssh_keypair_aws_override.public_key_openssh}"
}

output "ssh_key_name" {
  value = "${module.ssh_keypair_aws_override.name}"
}

output "consul_asg_id" {
  value = "${module.consul_aws.consul_asg_id}"
}

output "consul_sg_id" {
  value = "${module.consul_aws.consul_sg_id}"
}

output "consul_lb_sg_id" {
  value = "${module.consul_aws.consul_lb_sg_id}"
}

output "consul_tg_http_8500_arn" {
  value = "${module.consul_aws.consul_tg_http_8500_arn}"
}

output "consul_tg_https_8080_arn" {
  value = "${module.consul_aws.consul_tg_https_8080_arn}"
}

output "consul_lb_dns" {
  value = "${module.consul_aws.consul_lb_dns}"
}

output "vault_asg_id" {
  value = "${module.vault_aws.vault_asg_id}"
}

output "vault_sg_id" {
  value = "${module.vault_aws.vault_sg_id}"
}

output "vault_lb_sg_id" {
  value = "${module.vault_aws.vault_lb_sg_id}"
}

output "vault_tg_http_8200_arn" {
  value = "${module.vault_aws.vault_tg_http_8200_arn}"
}

output "vault_tg_https_8200_arn" {
  value = "${module.vault_aws.vault_tg_https_8200_arn}"
}

output "vault_lb_dns" {
  value = "${module.vault_aws.vault_lb_dns}"
}
