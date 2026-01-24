# Frontend EC2 Instance (Express)
resource "aws_instance" "frontend" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[1].id
  vpc_security_group_ids = [aws_security_group.frontend.id]
  key_name               = var.key_name

 # ec2_frontend.tf

user_data = templatefile("${path.module}/user_data_scripts/frontend_setup.sh", {
  # Provide both so the script is happy regardless of casing
  BACKEND_URL  = "http://${aws_eip.backend.public_ip}:5000"
  backend_url  = "http://${aws_eip.backend.public_ip}:5000"
  
  EXPRESS_PORT = "3000"
  express_port = "3000" 
})
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-frontend"
    Role = "Frontend"
  }

  depends_on = [aws_eip.backend]
}

# Elastic IP for Frontend (Optional but recommended)
resource "aws_eip" "frontend" {
  instance = aws_instance.frontend.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-frontend-eip"
  }

  depends_on = [aws_internet_gateway.main]
}