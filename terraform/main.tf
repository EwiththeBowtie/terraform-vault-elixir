provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "tf-vault-elixir-remote-state"
    key    = "vault/terraform.tfstate"
    region = "us-west-2"
  }
}
