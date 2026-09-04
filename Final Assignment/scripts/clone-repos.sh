#!/bin/bash

# ============================================================================
# Repository Cloning Script
# ============================================================================
# This script clones Flask and Express repositories to the EC2 instance
# ============================================================================

set -e  # Exit on error

# Configuration
APP_DIR="$HOME/apps"
FLASK_REPO_URL="${1:-}"  # First argument
EXPRESS_REPO_URL="${2:-}"  # Second argument

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
echo "Repository Cloning Script"
echo "============================================"
echo ""

# Check if repository URLs are provided
if [ -z "$FLASK_REPO_URL" ] || [ -z "$EXPRESS_REPO_URL" ]; then
    print_error "Repository URLs not provided"
    echo ""
    echo "Usage: ./clone-repos.sh <flask-repo-url> <express-repo-url>"
    echo ""
    echo "Example:"
    echo "  ./clone-repos.sh https://github.com/user/flask-backend.git https://github.com/user/express-frontend.git"
    echo ""
    exit 1
fi

# Create application directory
print_info "Creating application directory..."
mkdir -p "$APP_DIR"
cd "$APP_DIR"
print_success "Application directory created: $APP_DIR"

# Clone Flask Backend
print_info "Cloning Flask Backend repository..."
if [ -d "flask-backend" ]; then
    print_info "Flask directory exists, updating..."
    cd flask-backend
    git pull
    cd ..
else
    git clone "$FLASK_REPO_URL" flask-backend
fi
print_success "Flask Backend cloned"

# Clone Express Frontend
print_info "Cloning Express Frontend repository..."
if [ -d "express-frontend" ]; then
    print_info "Express directory exists, updating..."
    cd express-frontend
    git pull
    cd ..
else
    git clone "$EXPRESS_REPO_URL" express-frontend
fi
print_success "Express Frontend cloned"

echo ""
echo "============================================"
echo "CLONING COMPLETE!"
echo "============================================"
echo ""
echo "Repositories cloned to:"
echo "  - Flask:   $APP_DIR/flask-backend"
echo "  - Express: $APP_DIR/express-frontend"
echo ""
echo "Next steps:"
echo "  1. Setup Flask: cd $APP_DIR/flask-backend && python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt"
echo "  2. Setup Express: cd $APP_DIR/express-frontend && npm install"
echo "  3. Run deployment script: ./deploy.sh"
echo ""
print_success "Clone complete!"
