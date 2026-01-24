terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

provider "aws" {
  region = var.aws_region
}

# Security Group
resource "aws_security_group" "flask_express_sg" {
  name        = "flask-express-sg"
  description = "Security group for Flask and Express applications"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Express Frontend"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Flask Backend"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
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
    Name = "flask-express-sg"
  }
}

resource "aws_instance" "flask_express_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.flask_express_sg.id]
  
  # ADD THIS LINE:
  subnet_id              = data.aws_subnets.default.ids[0] 

  user_data = file("${path.module}/user-data.sh")
  # ... rest of your code
}

# Elastic IP (Optional - for static IP)
resource "aws_eip" "flask_express_eip" {
  instance = aws_instance.flask_express_instance.id
  domain   = "vpc"

  tags = {
    Name = "flask-express-eip"
  }
}