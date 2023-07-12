terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

variable "latest_ami_id" {
  type    = string
  default = "ami-06ca3ca175f37dd66"
  # I can't find a way to fetch the latest AMI id for Amazon Linux
  # the same way the CloudFormation template does.
}

variable "ssh_and_http_location" {
  type    = string
  default = "0.0.0.0/0"
}

variable "aws_profile" {
  type = string
}

provider "aws" {
  region  = "us-east-1"
  profile = var.aws_profile
}

resource "aws_instance" "ec2_instance" {
  instance_type        = "t2.micro"
  ami                  = var.latest_ami_id
  security_groups      = [aws_security_group.allow_ssh_and_http.name]
  iam_instance_profile = aws_iam_instance_profile.session_manager_instance_profile.name
}

resource "aws_security_group" "allow_ssh_and_http" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_and_http_location]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "session_manager_role" {
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  path                = "/"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
}

resource "aws_iam_instance_profile" "session_manager_instance_profile" {
  path = "/"
  role = aws_iam_role.session_manager_role.name
}

output "instance_id" {
  value = aws_instance.ec2_instance.id
}

output "az" {
  value = aws_instance.ec2_instance.availability_zone
}

output "public_dns" {
  value = aws_instance.ec2_instance.public_dns
}

output "public_ip" {
  value = aws_instance.ec2_instance.public_ip
}
