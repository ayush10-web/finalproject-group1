output "nonprod_public_ip" {
  value = aws_subnet.public_sn[*].id
}

output "nonprod_private_ip" {
  value = aws_subnet.private_sn[*].id
}

output "nonprod_vpc_id" {
  value = aws_vpc.nonprod.id
}

output "prod_vpc_id" {
  value = aws_vpc.prod.id
}

output "prod_private_ip" {
  value = aws_subnet.prod_private_sn[*].id
}

output "natgw" {
  value = aws_nat_gateway.natgw.id
}

output "igw" {
  value = aws_internet_gateway.igw.id
}

output "peeing_connection_id" {
  value = aws_vpc_peering_connection.prod_nonprod_connection.id
}