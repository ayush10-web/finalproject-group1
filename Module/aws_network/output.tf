output "public_ip" {
  value = aws_subnet.public_sn[*].id
}

output "private_ip" {
  value = aws_subnet.private_sn[*].id
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "natgw" {
  value = aws_nat_gateway.natgw.id
}

output "igw" {
  value = aws_internet_gateway.igw.id
}
