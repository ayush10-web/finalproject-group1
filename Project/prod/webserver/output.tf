output "instance_ip" {
  value = module.prod-webserver.instance_ip
}

output "bastion_public_ip" {
  value = module.prod-webserver.bastion_public_ip
}