#!/bin/bash

# ============================================================================
# Deployment Script for Flask + Express Applications
# ============================================================================
# This script deploys both Flask backend and Express frontend applications
# ============================================================================

set -e  # Exit on error

# Configuration
FLASK_DIR="$HOME/apps/flask-backend"
EXPRESS_DIR="$HOME/apps/express-frontend"
FLASK_PORT=5000
EXPRESS_PORT=3000

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

echo "============================================"
echo "Deployment Script"
echo "============================================"
echo ""

# Deploy Flask Backend
print_info "Deploying Flask Backend..."
if [ -d "$FLASK_DIR" ]; then
    cd "$FLASK_DIR"
    
    # Pull latest code
    print_info "Pulling latest Flask code..."
    git pull
    
    # Setup virtual environment
    print_info "Setting up Python virtual environment..."
    python3 -m venv venv
    source venv/bin/activate
    
    # Install dependencies
    print_info "Installing Flask dependencies..."
    pip install --upgrade pip
    pip install -r requirements.txt
    deactivate
    
    # Start with PM2
    print_info "Starting Flask with PM2..."
    if pm2 list | grep -q "flask-backend"; then
        pm2 restart flask-backend
    else
        pm2 start "source venv/bin/activate && python app.py" --name flask-backend
    fi
    
    print_success "Flask Backend deployed"
else
    print_error "Flask directory not found: $FLASK_DIR"
    print_info "Please clone the Flask repository first"
fi

echo ""

# Deploy Express Frontend
print_info "Deploying Express Frontend..."
if [ -d "$EXPRESS_DIR" ]; then
    cd "$EXPRESS_DIR"
    
    # Pull latest code
    print_info "Pulling latest Express code..."
    git pull
    
    # Install dependencies
    print_info "Installing npm dependencies..."
    npm install
    
    # Start with PM2
    print_info "Starting Express with PM2..."
    if pm2 list | grep -q "express-frontend"; then
        pm2 restart express-frontend
    else
        pm2 start npm --name express-frontend -- start
    fi
    
    print_success "Express Frontend deployed"
else
    print_error "Express directory not found: $EXPRESS_DIR"
    print_info "Please clone the Express repository first"
fi

echo ""

# Save PM2 configuration
print_info "Saving PM2 configuration..."
pm2 save

# Display status
echo ""
echo "============================================"
echo "DEPLOYMENT COMPLETE!"
echo "============================================"
echo ""
echo "PM2 Status:"
pm2 status

echo ""
echo "Application URLs:"
echo "  - Flask Backend:  http://$(curl -s ifconfig.me):$FLASK_PORT"
echo "  - Express Frontend: http://$(curl -s ifconfig.me):$EXPRESS_PORT"
echo ""

# Health checks
echo "Performing health checks..."
sleep 3

# Check Flask
if curl -f http://localhost:$FLASK_PORT/api/health > /dev/null 2>&1; then
    print_success "Flask Backend is healthy"
else
    print_error "Flask Backend health check failed"
fi

# Check Express
if curl -f http://localhost:$EXPRESS_PORT/health > /dev/null 2>&1; then
    print_success "Express Frontend is healthy"
else
    print_error "Express Frontend health check failed"
fi

echo ""
print_success "Deployment complete!"
