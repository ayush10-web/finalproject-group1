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
    key    = "${var.env}/network/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_instance" "vm" {
  count                       = length(data.terraform_remote_state.network_output.outputs.private_ip)
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
  key_name   = "${var.env}-Assignment_key"
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
    Name = "${var.env}--Bastion_VM"
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
    Name = "${var.env}--Bastion_SG"
  }
}

resource "aws_security_group" "web_alb_sg" {
  name        = "web_alb_sg"
  description = "Security group for ALB"
  vpc_id      = data.terraform_remote_state.network_output.outputs.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-ALB-SG"
  }
}

resource "aws_lb" "web_alb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = data.terraform_remote_state.network_output.outputs.public_ip
  security_groups    = [aws_security_group.web_alb_sg.id]

  tags = {
    Name = "Web-ALB"
  }
}

resource "aws_lb_target_group" "web_target_group" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network_output.outputs.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "Web-Target-Group"
  }
}

resource "aws_lb_target_group_attachment" "vm1_attachment" {
  count            = length(aws_instance.vm)
  target_group_arn = aws_lb_target_group.web_target_group.arn
  target_id        = aws_instance.vm[count.index].id
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.arn
  }
}

resource "aws_launch_configuration" "web_launch_config" {
  name_prefix   = "${var.env}-web-launch-config"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_types[var.env]
  key_name      = aws_key_pair.web_key.key_name
  security_groups = [aws_security_group.vm_sg.id]
  user_data     = file("${path.module}/install_httpd.sh.tpl")

  root_block_device {
    encrypted = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web_asg" {
  name                 = "${var.env}-web-asg"
  vpc_zone_identifier  = data.terraform_remote_state.network_output.outputs.private_ip
  launch_configuration = aws_launch_configuration.web_launch_config.name
  min_size             = 1
  max_size             = 3
  desired_capacity     = 2

  tag {
    key                 = "Name"
    value               = "${var.env}-Web-Instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

