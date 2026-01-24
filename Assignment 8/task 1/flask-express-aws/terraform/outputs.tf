output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.flask_express_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.flask_express_eip.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.flask_express_instance.public_dns
}

output "frontend_url" {
  description = "Frontend application URL"
  value       = "http://${aws_eip.flask_express_eip.public_ip}:3000"
}

output "backend_url" {
  description = "Backend API URL"
  value       = "http://${aws_eip.flask_express_eip.public_ip}:5000"
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_eip.flask_express_eip.public_ip}"
}