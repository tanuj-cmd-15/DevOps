variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1" # Changed from us-east-1
}

variable "ami_id" {
  description = "AMI ID for Ubuntu 22.04 LTS"
  type        = string
  default     = "ami-019715e0d74f695be" # This is a valid Ubuntu AMI in ap-south-1
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro" # Matching your previous successful plan
}

variable "key_name" {
  description = "Name of the key pair in AWS"
  type        = string
  default     = "window" # Use the name 'window' if your file is window.pem
}