Host bastion
  Hostname ${bastion_ip}
  User ec2-user
  IdentityFile ${path}/${private_key_filename}
  ForwardAgent yes

Host vault.service.consul 
  IdentityFile ${path}/${private_key_filename}
  User ec2-user
  ProxyCommand ssh -W %h:%p  ec2-user@bastion

