provider "aws" {
  region = "us-east-1"
}

//fetching the image for the instance
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

//retrieving the network configuration
data "terraform_remote_state" "network_output" {
  backend = "s3"
  config = {
    bucket = "finalprojectacs"
    key    = "${var.env}/network/terraform.tfstate"
    region = "us-east-1"
  }
}

//creating the vm for the prod
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

//setting up the key pair
resource "aws_key_pair" "web_key" {
  key_name   = "${var.env}-Assignment_key"
  public_key = file("finalproject.pub")
}

//creating the security group for the vm
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

//creating the bastion host
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

//security group for the bastion host
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

//creating the security group for the load balancer
resource "aws_security_group" "lb_sg" {
  name        = "lb_sg"
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
    Name = "ALB-SG"
  }
}

//creating the load balancer
resource "aws_lb" "ALB" {
  name               = "ALB"
  internal           = false
  load_balancer_type = "application"
  subnets            = data.terraform_remote_state.network_output.outputs.public_ip
  security_groups    = [aws_security_group.lb_sg.id]

  tags = {
    Name = "ALB"
  }
}


//creating the target group
resource "aws_lb_target_group" "target_group" {
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

resource "aws_lb_listener" "web_alb_listener" {
  load_balancer_arn = aws_lb.ALB.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

//creating the launch template as the ami of our vm
resource "aws_launch_template" "web_launch_template" {
  name_prefix      = "${var.env}-web-launch-template"
  image_id         = data.aws_ami.latest_amazon_linux.id
  instance_type    = var.instance_types[var.env]
  key_name         = aws_key_pair.web_key.key_name
  user_data        = base64encode(file("${path.module}/install_httpd.sh.tpl"))

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 50
      volume_type = "gp2"
      encrypted   = true
    }
  }

  network_interfaces {
    security_groups = [aws_security_group.vm_sg.id]
    associate_public_ip_address = false
  }

  lifecycle {
    create_before_destroy = true
  }
}

//creating the auto scaling group
resource "aws_autoscaling_group" "ASG" {
  name                 = "${var.env}-web-asg"
  vpc_zone_identifier  = data.terraform_remote_state.network_output.outputs.private_ip
  launch_template {
    id      = aws_launch_template.web_launch_template.id
    version = aws_launch_template.web_launch_template.latest_version
  }
  min_size             = 1
  max_size             = 4
  desired_capacity     = 2

  target_group_arns = [aws_lb_target_group.target_group.arn]

  tag {
    key                 = "Name"
    value               = "${var.env}-Web-Instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

//creating the scale out policy as per cpu usage
resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "${var.env}-scale-out-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.ASG.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 10  
  }
}

//creating the scale in policy as per cpu usage
resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "${var.env}-scale-in-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.ASG.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 5  
  }
}