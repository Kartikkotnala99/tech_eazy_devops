###########################################
# Terraform & Provider
###########################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "random_id" "rand" {
  byte_length = 4
}

###########################################
# Key Pair
###########################################
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "my-key-${random_id.rand.hex}"
  public_key = tls_private_key.my_key.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.my_key.private_key_pem
  filename = "${path.module}/my-key.pem"
  file_permission = "0400"
}

###########################################
# S3 Buckets
###########################################
# Existing bucket jar5 (used for app)
# New bucket for ALB logs
resource "aws_s3_bucket" "alb_logs" {
  bucket        = "alb-logs-${random_id.rand.hex}"
  force_destroy = true
}

###########################################
# IAM Role for EC2 → S3
###########################################
resource "aws_iam_role" "ec2_s3_role" {
  name = "EC2-S3-Access-Role-${random_id.rand.hex}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "s3_policy" {
  name = "EC2S3AccessPolicy"
  role = aws_iam_role.ec2_s3_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::jar5",
          "arn:aws:s3:::jar5/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-s3-profile-${random_id.rand.hex}"
  role = aws_iam_role.ec2_s3_role.name
}

###########################################
# Security Groups
###########################################
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP from Internet"
  vpc_id      = var.vpc_id

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
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow ALB + SSH access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

###########################################
# EC2 Instances (3)
###########################################
resource "aws_instance" "app_server" {
  count                  = 3
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = element(var.public_subnets, count.index)
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  key_name               = aws_key_pair.generated_key.key_name
  user_data              = file("${path.module}/user.sh")

  tags = {
    Name = "app-server-${count.index + 1}"
  }
}

###########################################
# Load Balancer Setup
###########################################
resource "aws_lb" "app_alb" {
  name               = "app-alb-${random_id.rand.hex}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnets

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    enabled = true
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg-${random_id.rand.hex}"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    port                = "8080"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "app_attachment" {
  count            = 3
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app_server[count.index].id
  port             = 8080
}

###########################################
# Outputs
###########################################


output "private_key_pem" {
  sensitive = true
  value     = tls_private_key.my_key.private_key_pem
}
