output "instance_ip" {
  value = module.staging-webserver.instance_ip
}

output "bastion_public_ip" {
  value = module.staging-webserver.bastion_public_ip
}