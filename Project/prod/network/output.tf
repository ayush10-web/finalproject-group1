output "public_ip" {
  value = module.vpc-prod.public_ip
}

output "private_ip" {
  value = module.vpc-prod.private_ip
}

output "vpc_id" {
  value = module.vpc-prod.vpc_id
}