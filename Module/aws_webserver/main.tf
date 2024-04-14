provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "terraform_remote_state" "network_output" {
  backend = "s3"
  config = {
    bucket = "finalprojectacs"
    key    = "dev/network/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_instance" "vm1" {
  count                       = length( data.terraform_remote_state.network_output.outputs.private_ip)
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.instance_types[var.env]
  key_name                    = aws_key_pair.web_key.key_name
  security_groups             = [aws_security_group.vm_sg.id]
  subnet_id                   = data.terraform_remote_state.network_output.outputs.private_ip[count.index]
  associate_public_ip_address = false
  user_data                   = file("${path.module}/install_httpd.sh.tpl")

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "${var.env}--VM-${count.index + 1}"
  }

}

resource "aws_key_pair" "web_key" {
  key_name   = "Assignment_key"
  public_key = file("finalproject.pub")
}

resource "aws_security_group" "vm_sg" {
  name        = "allow_http_ssh"
  description = "allow http ssh from bastion"
  vpc_id      = data.terraform_remote_state.network_output.outputs.vpc_id

  ingress {
    description      = "allow http from bastion host"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "allow ssh  from bastion host"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  tags = {
    Name = "${var.env}-VM-Bastion_SG"
  }
}


resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.instance_types[var.env]
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = data.terraform_remote_state.network_output.outputs.public_ip[1]
  security_groups             = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "Bastion_VM"
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion_allow_http_ssh"
  description = "allow http ssh for bastion"
  vpc_id      = data.terraform_remote_state.network_output.outputs.vpc_id

  ingress {
    description      = "allow http  from bastion host"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "allow ssh  from bastion host"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  tags = {
    Name = "Bastion_SG"
  }
}

