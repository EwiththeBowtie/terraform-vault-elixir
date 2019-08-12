name           = "tf-vault-elixir"
bastion_instance       = "t3.nano"

network_tags = {"owner" = "tf-vault-elixir", "TTL" = "24"}

# ---------------------------------------------------------------------------------------------------------------------
# Consul Variables
# ---------------------------------------------------------------------------------------------------------------------
# consul_servers    = 1 # Number of Consul servers to provision across public subnets, defaults to public subnet count.
consul_instance   = "t3.nano"
consul_tags = {"owner" = "tf-vault-elixir", "TTL" = "24"}

# ---------------------------------------------------------------------------------------------------------------------
# Vault Variables
# ---------------------------------------------------------------------------------------------------------------------
vault_servers    = 1 # Number of Vault servers, defaults to public count
vault_instance   = "t3.nano"
vault_release    = "1.2.1"
vault_version    = "1.2.1"
