output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "backend_instance_id" {
  description = "Backend EC2 Instance ID"
  value       = aws_instance.backend.id
}

output "backend_public_ip" {
  description = "Backend Public IP"
  value       = aws_eip.backend.public_ip
}

output "backend_private_ip" {
  description = "Backend Private IP"
  value       = aws_instance.backend.private_ip
}

output "frontend_instance_id" {
  description = "Frontend EC2 Instance ID"
  value       = aws_instance.frontend.id
}

output "frontend_public_ip" {
  description = "Frontend Public IP"
  value       = aws_eip.frontend.public_ip
}

output "frontend_private_ip" {
  description = "Frontend Private IP"
  value       = aws_instance.frontend.private_ip
}

output "backend_url" {
  description = "Backend API URL"
  value       = "http://${aws_eip.backend.public_ip}:5000"
}

output "frontend_url" {
  description = "Frontend Application URL"
  value       = "http://${aws_eip.frontend.public_ip}:3000"
}

output "ssh_commands" {
  description = "SSH commands to connect to instances"
  value = {
    backend  = "ssh -i ${var.key_name}.pem ubuntu@${aws_eip.backend.public_ip}"
    frontend = "ssh -i ${var.key_name}.pem ubuntu@${aws_eip.frontend.public_ip}"
  }
}