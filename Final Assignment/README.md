# Jenkins CI/CD Pipeline - DevOps Assignment

## Project Overview
This project demonstrates the deployment of a Flask backend and Express frontend on an Amazon EC2 instance with automated CI/CD pipeline using Jenkins.

## Architecture
```
EC2 Instance
├── Flask Backend (Port 5000) - REST API
├── Express Frontend (Port 3000) - Web Application
└── Jenkins (Port 8080) - CI/CD Automation
```

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Part 1: EC2 Deployment](#part-1-ec2-deployment)
3. [Part 2: Jenkins CI/CD Pipeline](#part-2-jenkins-cicd-pipeline)
4. [Testing the Setup](#testing-the-setup)
5. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### AWS Account Requirements
- AWS Account with EC2 access
- Security Group configured with the following inbound rules:
  - SSH (Port 22) - Your IP
  - HTTP (Port 80) - Anywhere
  - Custom TCP (Port 3000) - Anywhere (Express)
  - Custom TCP (Port 5000) - Anywhere (Flask)
  - Custom TCP (Port 8080) - Anywhere (Jenkins)

### Local Requirements
- SSH client
- Git
- GitHub account

---

## Part 1: EC2 Deployment

### Step 1: Launch EC2 Instance

1. **Login to AWS Console**
   - Navigate to EC2 Dashboard
   - Click "Launch Instance"

2. **Configure Instance**
   - Name: `Jenkins-CICD-Server`
   - AMI: Ubuntu Server 22.04 LTS (Free tier eligible)
   - Instance Type: t2.medium (recommended for Jenkins) or t2.micro (minimum)
   - Key Pair: Create new or use existing
   - Storage: 20 GB gp2

3. **Configure Security Group**
   ```
   Type            Protocol    Port Range    Source
   SSH             TCP         22            My IP
   HTTP            TCP         80            0.0.0.0/0
   Custom TCP      TCP         3000          0.0.0.0/0
   Custom TCP      TCP         5000          0.0.0.0/0
   Custom TCP      TCP         8080          0.0.0.0/0
   ```

4. **Launch Instance**
   - Download the .pem key file
   - Note the Public IP address

### Step 2: Connect to EC2 Instance

```bash
# Set key permissions (Linux/Mac)
chmod 400 your-key.pem

# Connect via SSH
ssh -i your-key.pem ubuntu@<your-ec2-public-ip>
```

For Windows:
```powershell
# Use PowerShell or PuTTY
ssh -i your-key.pem ubuntu@<your-ec2-public-ip>
```

### Step 3: Install Dependencies on EC2

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Python and pip
sudo apt install python3 python3-pip python3-venv -y

# Install Node.js and npm
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install nodejs -y

# Verify installations
python3 --version
pip3 --version
node --version
npm --version

# Install PM2 (Process Manager)
sudo npm install -g pm2

# Install Git
sudo apt install git -y
```

### Step 4: Clone and Setup Applications

```bash
# Create application directory
mkdir -p ~/apps
cd ~/apps

# Clone Flask Backend
git clone <your-flask-repo-url> flask-backend
cd flask-backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
deactivate
cd ..

# Clone Express Frontend
git clone <your-express-repo-url> express-frontend
cd express-frontend
npm install
cd ..
```

### Step 5: Start Applications with PM2

```bash
# Start Flask Backend
cd ~/apps/flask-backend
pm2 start "source venv/bin/activate && python app.py" --name flask-backend

# Start Express Frontend
cd ~/apps/express-frontend
pm2 start npm --name express-frontend -- start

# Save PM2 configuration
pm2 save
pm2 startup

# Check status
pm2 status
pm2 logs
```

### Step 6: Test Applications

```bash
# Test Flask API
curl http://localhost:5000/api/health

# Test Express Frontend
curl http://localhost:3000
```

**Access via browser:**
- Flask API: `http://<ec2-public-ip>:5000`
- Express Frontend: `http://<ec2-public-ip>:3000`

---

## Part 2: Jenkins CI/CD Pipeline

### Step 1: Install Jenkins

```bash
# Install Java (Jenkins requirement)
sudo apt install openjdk-11-jdk -y
java -version

# Add Jenkins repository
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
sudo apt update
sudo apt install jenkins -y

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo systemctl status jenkins

# Get initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Step 2: Configure Jenkins

1. **Access Jenkins**
   - Open browser: `http://<ec2-public-ip>:8080`
   - Enter the initial admin password
   - Install suggested plugins

2. **Install Additional Plugins**
   - Navigate to: Manage Jenkins → Manage Plugins → Available
   - Install:
     - Git plugin
     - GitHub Integration Plugin
     - NodeJS Plugin
     - Pipeline Plugin
     - SSH Agent Plugin

3. **Configure Tools**
   - Navigate to: Manage Jenkins → Global Tool Configuration
   
   **NodeJS:**
   - Add NodeJS → Name: `NodeJS-18` → Version: NodeJS 18.x
   - Install automatically

   **Git:**
   - Should be auto-detected

### Step 3: Create Jenkins Credentials

1. **Navigate to:** Manage Jenkins → Manage Credentials → System → Global credentials
2. **Add Credentials:**
   - Kind: SSH Username with private key
   - ID: `ec2-ssh-key`
   - Username: `ubuntu`
   - Private Key: Paste your EC2 .pem key content

### Step 4: Create Jenkins Pipeline for Flask Backend

1. **Create New Item**
   - Name: `Flask-Backend-Pipeline`
   - Type: Pipeline
   - Click OK

2. **Configure Pipeline**
   - Description: "CI/CD Pipeline for Flask Backend"
   - Check "GitHub project" → Add your repo URL
   - Check "GitHub hook trigger for GITScm polling"

3. **Pipeline Script**
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: Your Flask repo
   - Credentials: Select if private repo
   - Branch: */main (or */master)
   - Script Path: Jenkinsfile

### Step 5: Create Jenkins Pipeline for Express Frontend

1. **Create New Item**
   - Name: `Express-Frontend-Pipeline`
   - Type: Pipeline
   - Click OK

2. **Configure Pipeline**
   - Description: "CI/CD Pipeline for Express Frontend"
   - Check "GitHub project" → Add your repo URL
   - Check "GitHub hook trigger for GITScm polling"

3. **Pipeline Script**
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: Your Express repo
   - Credentials: Select if private repo
   - Branch: */main (or */master)
   - Script Path: Jenkinsfile

### Step 6: Configure GitHub Webhooks

1. **Go to GitHub Repository Settings**
   - Navigate to: Settings → Webhooks → Add webhook

2. **Configure Webhook**
   - Payload URL: `http://<ec2-public-ip>:8080/github-webhook/`
   - Content type: application/json
   - Events: Just the push event
   - Active: Checked

3. **Repeat for both repositories** (Flask and Express)

### Step 7: Test the Pipeline

1. **Manual Build**
   - Go to Jenkins Dashboard
   - Click on pipeline name
   - Click "Build Now"
   - Check Console Output

2. **Automatic Build (via Git Push)**
   - Make a change to your code
   - Commit and push to GitHub
   - Jenkins should automatically trigger the build

---

## Testing the Setup

### Test Flask API Endpoints

```bash
# Health check
curl http://<ec2-public-ip>:5000/api/health

# Get all items
curl http://<ec2-public-ip>:5000/api/items

# Add new item
curl -X POST http://<ec2-public-ip>:5000/api/items \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Item","description":"Test Description"}'
```

### Test Express Frontend

Open browser: `http://<ec2-public-ip>:3000`

### Monitor Applications

```bash
# Check PM2 status
pm2 status

# View logs
pm2 logs flask-backend
pm2 logs express-frontend

# Restart applications
pm2 restart flask-backend
pm2 restart express-frontend
```

---

## Troubleshooting

### Common Issues

1. **Port Already in Use**
   ```bash
   # Find process using port
   sudo lsof -i :5000
   sudo lsof -i :3000
   
   # Kill process
   kill -9 <PID>
   ```

2. **PM2 Not Starting**
   ```bash
   # Delete PM2 process
   pm2 delete flask-backend
   pm2 delete express-frontend
   
   # Start again
   pm2 start <command>
   ```

3. **Jenkins Build Failing**
   - Check Console Output in Jenkins
   - Verify GitHub webhook is configured correctly
   - Ensure Jenkins has proper permissions
   - Check Jenkinsfile syntax

4. **Cannot Access Applications**
   - Verify EC2 Security Group rules
   - Check if applications are running: `pm2 status`
   - Check firewall: `sudo ufw status`

### Useful Commands

```bash
# Check application status
pm2 status
sudo systemctl status jenkins

# View logs
pm2 logs
sudo journalctl -u jenkins

# Restart services
pm2 restart all
sudo systemctl restart jenkins

# Check ports
sudo netstat -tlnp | grep -E '3000|5000|8080'
```

---

## Project Structure

```
Jenkins_CICD_YourName/
├── flask-backend/
│   ├── app.py
│   ├── requirements.txt
│   ├── Jenkinsfile
│   └── README.md
├── express-frontend/
│   ├── server.js
│   ├── package.json
│   ├── Jenkinsfile
│   └── public/
│       ├── index.html
│       ├── style.css
│       └── script.js
├── screenshots/
│   ├── ec2-instance.png
│   ├── security-group.png
│   ├── flask-running.png
│   ├── express-running.png
│   ├── jenkins-dashboard.png
│   ├── jenkins-flask-pipeline.png
│   ├── jenkins-express-pipeline.png
│   ├── github-webhook.png
│   └── successful-deployment.png
├── scripts/
│   ├── setup-ec2.sh
│   └── deploy.sh
└── README.md (this file)
```

---

## GitHub Repository Links

- **Flask Backend:** `<your-flask-repo-url>`
- **Express Frontend:** `<your-express-repo-url>`

---

## Conclusion

This project demonstrates a complete CI/CD pipeline using Jenkins to automate the deployment of Flask and Express applications on AWS EC2. Every push to the GitHub repository triggers an automatic build and deployment, ensuring continuous integration and delivery.

---

## Author

**Your Name**  
Date: [Current Date]  
Course: DevOps - Jenkins CI/CD Pipeline Assignment
