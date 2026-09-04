#!/bin/bash

# ============================================================================
# EC2 Setup Script for Flask + Express + Jenkins
# ============================================================================
# This script automates the setup of an EC2 instance with all required
# dependencies for running Flask backend, Express frontend, and Jenkins
# ============================================================================

set -e  # Exit on error

echo "============================================"
echo "EC2 Instance Setup Script"
echo "============================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}➜ $1${NC}"
}

# Update system
print_info "Updating system packages..."
sudo apt update && sudo apt upgrade -y
print_success "System updated"

# Install Python and pip
print_info "Installing Python and pip..."
sudo apt install -y python3 python3-pip python3-venv
python3 --version
pip3 --version
print_success "Python installed"

# Install Node.js and npm
print_info "Installing Node.js and npm..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
node --version
npm --version
print_success "Node.js installed"

# Install PM2
print_info "Installing PM2 process manager..."
sudo npm install -g pm2
pm2 --version
print_success "PM2 installed"

# Install Git
print_info "Installing Git..."
sudo apt install -y git
git --version
print_success "Git installed"

# Install Java (required for Jenkins)
print_info "Installing Java..."
sudo apt install -y openjdk-11-jdk
java -version
print_success "Java installed"

# Install Jenkins
print_info "Installing Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y jenkins
print_success "Jenkins installed"

# Start Jenkins
print_info "Starting Jenkins..."
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo systemctl status jenkins --no-pager
print_success "Jenkins started"

# Get Jenkins initial password
print_info "Getting Jenkins initial admin password..."
echo ""
echo "============================================"
echo "JENKINS INITIAL ADMIN PASSWORD:"
echo "============================================"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "============================================"
echo ""

# Create application directory
print_info "Creating application directory..."
mkdir -p ~/apps
cd ~/apps
print_success "Application directory created"

# Configure firewall (if ufw is installed)
if command -v ufw &> /dev/null; then
    print_info "Configuring firewall..."
    sudo ufw allow 22/tcp
    sudo ufw allow 80/tcp
    sudo ufw allow 3000/tcp
    sudo ufw allow 5000/tcp
    sudo ufw allow 8080/tcp
    print_success "Firewall configured"
fi

# Display system information
echo ""
echo "============================================"
echo "INSTALLATION COMPLETE!"
echo "============================================"
echo ""
echo "Installed versions:"
echo "  - Python: $(python3 --version)"
echo "  - Node.js: $(node --version)"
echo "  - npm: $(npm --version)"
echo "  - PM2: $(pm2 --version)"
echo "  - Git: $(git --version)"
echo "  - Java: $(java -version 2>&1 | head -n 1)"
echo ""
echo "Services running:"
echo "  - Jenkins: http://$(curl -s ifconfig.me):8080"
echo ""
echo "Next steps:"
echo "  1. Access Jenkins at http://YOUR_EC2_IP:8080"
echo "  2. Use the initial admin password above"
echo "  3. Clone your Flask and Express repositories to ~/apps/"
echo "  4. Configure Jenkins pipelines"
echo ""
echo "Application directories:"
echo "  - Flask: ~/apps/flask-backend"
echo "  - Express: ~/apps/express-frontend"
echo ""
print_success "Setup complete!"
