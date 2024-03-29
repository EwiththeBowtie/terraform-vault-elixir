terraform {
  backend "s3" {
    bucket = "tf-vault-elixir-remote-state"
    key    = "vault/terraform.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
}

data "aws_ami" "vault-consul-amazon-linux-2" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["vault-consul-amazon-linux-2-*"]
  }
}

module "ssh_keypair_aws_override" {
  source = "github.com/hashicorp-modules/ssh-keypair-aws"

  name = "${var.name}-override"
}

module "consul_auto_join_instance_role" {
  source = "github.com/hashicorp-modules/consul-auto-join-instance-role-aws"

  name = "${var.name}"
}

resource "random_id" "consul_encrypt" {
  byte_length = 16
}

module "root_tls_self_signed_ca" {
  source = "github.com/hashicorp-modules/tls-self-signed-cert"

  name              = "${var.name}-root"
  ca_common_name    = "${var.common_name}"
  organization_name = "${var.organization_name}"
  common_name       = "${var.common_name}"
  download_certs    = "${var.download_certs}"

  validity_period_hours = "8760"

  ca_allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

module "leaf_tls_self_signed_cert" {
  source = "github.com/hashicorp-modules/tls-self-signed-cert"

  name              = "${var.name}-leaf"
  organization_name = "${var.organization_name}"
  common_name       = "${var.common_name}"
  ca_override       = true
  ca_key_override   = "${module.root_tls_self_signed_ca.ca_private_key_pem}"
  ca_cert_override  = "${module.root_tls_self_signed_ca.ca_cert_pem}"
  download_certs    = "${var.download_certs}"

  validity_period_hours = "8760"

  dns_names = [
    "localhost",
    "*.node.consul",
    "*.service.consul",
    "server.dc1.consul",
    "*.dc1.consul",
    "server.${var.name}.consul",
    "*.${var.name}.consul",
  ]

  ip_addresses = [
    "0.0.0.0",
    "127.0.0.1",
  ]

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

data "template_file" "bastion_user_data" {
  template = "${file("${path.module}/templates/best-practices-bastion-systemd.sh.tpl")}"

  vars = {
    name            = "${var.name}"
    provider        = "${var.provider}"
    local_ip_url    = "${var.local_ip_url}"
    ca_crt          = "${module.root_tls_self_signed_ca.ca_cert_pem}"
    leaf_crt        = "${module.leaf_tls_self_signed_cert.leaf_cert_pem}"
    leaf_key        = "${module.leaf_tls_self_signed_cert.leaf_private_key_pem}"
    consul_encrypt  = "${random_id.consul_encrypt.b64_std}"
    consul_override = "${var.consul_client_config_override != "" ? true : false}"
    consul_config   = "${var.consul_client_config_override}"
  }
}

module "network_aws" {
  source = "github.com/hashicorp-modules/network-aws"

  name              = "${var.name}"
  vpc_cidr          = "${var.vpc_cidr}"
  vpc_cidrs_public  = "${var.vpc_cidrs_public}"
  nat_count         = "${var.nat_count}"
  vpc_cidrs_private = "${var.vpc_cidrs_private}"
  release_version   = "${var.bastion_release}"
  consul_version    = "${var.bastion_consul_version}"
  vault_version     = "${var.bastion_vault_version}"
  os                = "${var.bastion_os}"
  os_version        = "${var.bastion_os_version}"
  bastion_count     = "${var.bastion_servers}"
  instance_profile  = "${module.consul_auto_join_instance_role.instance_profile_id}" # override instance_profile
  instance_type     = "${var.bastion_instance}"
  image_id          = "${data.aws_ami.vault-consul-amazon-linux-2.image_id}"
  user_data         = "${data.template_file.bastion_user_data.rendered}"             # override user_data
  ssh_key_name      = "${module.ssh_keypair_aws_override.name}"
  ssh_key_override  = true
  private_key_file  = "${module.ssh_keypair_aws_override.private_key_filename}"
  tags              = "${var.network_tags}"
}

data "template_file" "consul_user_data" {
  template = "${file("${path.module}/templates/best-practices-consul-systemd.sh.tpl")}"

  vars = {
    name             = "${var.name}"
    provider         = "${var.provider}"
    local_ip_url     = "${var.local_ip_url}"
    ca_crt           = "${module.root_tls_self_signed_ca.ca_cert_pem}"
    leaf_crt         = "${module.leaf_tls_self_signed_cert.leaf_cert_pem}"
    leaf_key         = "${module.leaf_tls_self_signed_cert.leaf_private_key_pem}"
    consul_bootstrap = "${length(module.network_aws.subnet_private_ids)}"
    consul_encrypt   = "${random_id.consul_encrypt.b64_std}"
    consul_override  = "${var.consul_client_config_override != "" ? true : false}"
    consul_config    = "${var.consul_client_config_override}"
  }
}

module "consul_aws" {
  source = "github.com/hashicorp-modules/consul-aws"

  name             = "${var.name}"                                                                                                                           # Must match network_aws module name for Consul Auto Join to work
  vpc_id           = "${module.network_aws.vpc_id}"
  vpc_cidr         = "${module.network_aws.vpc_cidr}"
  subnet_ids       = "${split(",", var.consul_public ? join(",", module.network_aws.subnet_public_ids) : join(",", module.network_aws.subnet_private_ids))}"
  release_version  = "${var.consul_release}"
  consul_version   = "${var.consul_version}"
  os               = "${var.consul_os}"
  os_version       = "${var.consul_os_version}"
  count            = "${var.consul_servers}"
  instance_profile = "${module.consul_auto_join_instance_role.instance_profile_id}"                                                                          # Override instance_profile
  instance_type    = "${var.consul_instance}"
  image_id         = "${data.aws_ami.vault-consul-amazon-linux-2.image_id}"
  public           = "${var.consul_public}"
  use_lb_cert      = true
  lb_cert          = "${module.leaf_tls_self_signed_cert.leaf_cert_pem}"
  lb_private_key   = "${module.leaf_tls_self_signed_cert.leaf_private_key_pem}"
  lb_cert_chain    = "${module.root_tls_self_signed_ca.ca_cert_pem}"
  user_data        = "${data.template_file.consul_user_data.rendered}"                                                                                       # Custom user_data
  ssh_key_name     = "${module.ssh_keypair_aws_override.name}"
  tags             = "${var.consul_tags}"
  tags_list        = "${var.consul_tags_list}"
}

data "aws_region" "current" {}

data "template_file" "vault_user_data" {
  template = "${file("${path.module}/templates/best-practices-vault-systemd.sh.tpl")}"

  vars = {
    name            = "${var.name}"
    provider        = "${var.provider}"
    aws_region      = "${data.aws_region.current.name}"
    kms_key         = "${aws_kms_key.vault.key_id}"
    local_ip_url    = "${var.local_ip_url}"
    ca_crt          = "${module.root_tls_self_signed_ca.ca_cert_pem}"
    leaf_crt        = "${module.leaf_tls_self_signed_cert.leaf_cert_pem}"
    leaf_key        = "${module.leaf_tls_self_signed_cert.leaf_private_key_pem}"
    consul_encrypt  = "${random_id.consul_encrypt.b64_std}"
    consul_override = "${var.consul_client_config_override != "" ? true : false}"
    consul_config   = "${var.consul_client_config_override}"
    vault_encrypt   = "${random_id.consul_encrypt.b64_std}"
    vault_override  = "${var.vault_server_config_override != "" ? true : false}"
    vault_config    = "${var.vault_server_config_override}"
  }
}

module "vault_aws" {
  source = "github.com/hashicorp-modules/vault-aws"

  name             = "${var.name}"                                                                                                                          # Must match network_aws module name for Consul Auto Join to work
  vpc_id           = "${module.network_aws.vpc_id}"
  vpc_cidr         = "${module.network_aws.vpc_cidr}"
  subnet_ids       = "${split(",", var.vault_public ? join(",", module.network_aws.subnet_public_ids) : join(",", module.network_aws.subnet_private_ids))}"
	release_version  = "${var.vault_release}" vault_version    =
	"${var.vault_version}"
	consul_version   = "${var.consul_version}"
  os               = "${var.vault_os}"
  os_version       = "${var.vault_os_version}"
  count            = "${var.vault_servers}"
  instance_profile = "${module.consul_auto_join_instance_role.instance_profile_id}"                                                                         # Override instance_profile
  instance_type    = "${var.vault_instance}"
  image_id         = "${data.aws_ami.vault-consul-amazon-linux-2.image_id}"
  public           = "${var.vault_public}"
  use_lb_cert      = true
  lb_cert          = "${module.leaf_tls_self_signed_cert.leaf_cert_pem}"
  lb_private_key   = "${module.leaf_tls_self_signed_cert.leaf_private_key_pem}"
  lb_cert_chain    = "${module.root_tls_self_signed_ca.ca_cert_pem}"
  user_data        = "${data.template_file.vault_user_data.rendered}"                                                                                       # Custom user_data
  ssh_key_name     = "${module.ssh_keypair_aws_override.name}"
  tags             = "${var.vault_tags}"
  tags_list        = "${var.vault_tags_list}"
}

resource "random_pet" "env" {
  length    = 2
  separator = "_"
}

resource "aws_kms_key" "vault" {
  description             = "Vault unseal key"
  deletion_window_in_days = 10

  tags = {
    Name = "vault-kms-unseal-${random_pet.env.id}"
  }
}

data "aws_iam_policy_document" "vault-kms-unseal" {
  statement {
    sid       = "VaultKMSUnseal"
    effect    = "Allow"
    resources = ["${aws_kms_key.vault.arn}"]

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
  }
}

resource "aws_iam_policy" "vault-kms-unseal" {
  name        = "vault-kms-unseal"
  description = "Allow vault instance profile to access kms-key for unsealing"

  policy = "${data.aws_iam_policy_document.vault-kms-unseal.json}"
}

resource "aws_iam_role_policy_attachment" "vault-kms-unseal" {
  role       = "${module.consul_auto_join_instance_role.iam_role_id}"
  policy_arn = "${aws_iam_policy.vault-kms-unseal.arn}"
}

data "aws_iam_policy_document" "vault-aws-iam" {
  statement {
    sid       = "VaultAwsIam"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "iam:GetUser",
			"iam:GetRole",
			"sts:AssumeRole"
    ]
  }
}

resource "aws_iam_policy" "vault-aws-iam" {
  name        = "vault-aws-iam"
  description = "Allow vault to get aws iam policies"

  policy = "${data.aws_iam_policy_document.vault-aws-iam.json}"
}

resource "aws_iam_role_policy_attachment" "vault-aws-iam" {
  role       = "${module.consul_auto_join_instance_role.iam_role_id}"
  policy_arn = "${aws_iam_policy.vault-aws-iam.arn}"
}

data "template_file" "ssh_config" {
  template = "${file("${path.module}/templates/terraform-vault-elixir.config.tpl")}"

  vars = {
    bastion_ip           = "${element(module.network_aws.bastion_ips_public,0)}"
    path                 = "${path.module}"
    private_key_filename = "${module.ssh_keypair_aws_override.private_key_filename}"
  }
}

resource "local_file" "ssh_config" {
  content  = "${data.template_file.ssh_config.rendered}"
	filename = "${path.module}/ssh.config"
}
