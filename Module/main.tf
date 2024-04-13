provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr_blocks[var.prefix]
  instance_tenancy = "default"

  tags = {
    Name = "${var.prefix}--VPC"
  }
}

resource "aws_subnet" "public_sn" {
  count             = length(var.public_sn)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_sn[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = {
    Name = "${var.prefix}--Public_SN${count.index + 1}"
  }
}

resource "aws_subnet" "private_sn" {
  count             = length(var.private_sn)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_sn[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = {
    Name = "${var.prefix}--Private_SN${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "IGW"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_sn[0].id

  tags = {
    Name = "NAT GW"
  }
}


resource "aws_route_table" "public_route_table" {
  count  = length(aws_subnet.public_sn)
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-Public route table ${count.index + 1}"
  }

}

resource "aws_route" "public_sn_routes" {
  count                  = length(aws_subnet.public_sn)
  route_table_id         = aws_route_table.public_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_sn_association" {
  count          = length(aws_subnet.public_sn)
  subnet_id      = aws_subnet.public_sn[count.index].id
  route_table_id = aws_route_table.public_route_table[count.index].id
}

resource "aws_route_table" "private_route_table" {
  count  = length(aws_subnet.private_sn)
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}--Private subnet route table ${count.index + 1}"
  }
}

resource "aws_route" "private_sn_routes" {
  count                  = length(aws_subnet.private_sn)
  route_table_id         = aws_route_table.private_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.natgw.id
}

resource "aws_route_table_association" "private_sn_association" {
  count          = length(aws_subnet.private_sn)
  subnet_id      = aws_subnet.private_sn[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}