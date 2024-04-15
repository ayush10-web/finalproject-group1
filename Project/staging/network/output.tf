output "public_ip" {
  value = module.vpc-staging.public_ip
}

output "private_ip" {
  value = module.vpc-staging.private_ip
}

output "vpc_id" {
  value = module.vpc-staging.vpc_id
}