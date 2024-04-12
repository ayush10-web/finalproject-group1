output "public_ip" {
  value = module.vpc-dev.public_ip
}

output "private_ip" {
  value = module.vpc-dev.private_ip
}

output "vpc_id" {
  value = module.vpc-dev.vpc_id
}

output "nat_gateway_id"{
  value = module.vpc-dev.nat_gateway_id
}