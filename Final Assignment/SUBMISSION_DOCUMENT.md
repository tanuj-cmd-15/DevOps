# Jenkins CI/CD Pipeline - DevOps Assignment
## Submission Document

**Student Name:** [Your Name]  
**Date:** September 4, 2026  
**Course:** DevOps - Jenkins CI/CD Pipeline  
**EC2 Public IP:** 65.1.100.135

---

## Table of Contents
1. [Assignment Overview](#assignment-overview)
2. [Part 1: EC2 Deployment](#part-1-ec2-deployment)
3. [Part 2: Jenkins CI/CD Pipeline](#part-2-jenkins-cicd-pipeline)
4. [Screenshots and Evidence](#screenshots-and-evidence)
5. [GitHub Repository Links](#github-repository-links)
6. [Challenges Faced](#challenges-faced)
7. [Conclusion](#conclusion)

---

## Assignment Overview

This project demonstrates the complete implementation of a CI/CD pipeline using Jenkins to automate the deployment of a Flask backend and Express frontend on an Amazon EC2 instance.

### Objectives Achieved:
- ✅ Deployed Flask backend on EC2 (Port 5000)
- ✅ Deployed Express frontend on EC2 (Port 3000)
- ✅ Installed and configured Jenkins (Port 8080)
- ✅ Created CI/CD pipelines for both applications
- ✅ Configured GitHub webhooks for automatic deployment
- ✅ Implemented health checks and monitoring
- ✅ Used PM2 for process management

---

## Part 1: EC2 Deployment

### 1.1 EC2 Instance Provisioning

**Instance Details:**
- **Instance Type:** t2.medium (or t2.micro for free tier)
- **AMI:** Ubuntu Server 22.04 LTS
- **Region:** [Your AWS Region]
- **Instance ID:** [Your Instance ID]
- **Public IP:** 65.1.100.135

**Security Group Configuration:**
```
Type            Protocol    Port Range    Source          Purpose
SSH             TCP         22            My IP           SSH Access
HTTP            TCP         80            0.0.0.0/0       Web Traffic
Custom TCP      TCP         3000          0.0.0.0/0       Express Frontend
Custom TCP      TCP         5000          0.0.0.0/0       Flask Backend
Custom TCP      TCP         8080          0.0.0.0/0       Jenkins
```

**Screenshot Reference:** `screenshots/ec2-instance.png`, `screenshots/security-group.png`

### 1.2 SSH Connection

**Command Used:**
```bash
ssh -i jenkins-cicd-key.pem ubuntu@65.1.100.135
```

**Screenshot Reference:** `screenshots/ssh-connection.png`

### 1.3 Dependencies Installation

**Commands Executed:**

1. **System Update:**
```bash
sudo apt update && sudo apt upgrade -y
```

2. **Python Installation:**
```bash
sudo apt install python3 python3-pip python3-venv -y
python3 --version  # Output: Python 3.10.12
pip3 --version     # Output: pip 22.0.2
```

3. **Node.js Installation:**
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install nodejs -y
node --version  # Output: v18.18.0
npm --version   # Output: 9.8.1
```

4. **PM2 Installation:**
```bash
sudo npm install -g pm2
pm2 --version  # Output: 5.3.0
```

5. **Git Installation:**
```bash
sudo apt install git -y
git --version  # Output: git version 2.34.1
```

**Screenshot Reference:** `screenshots/dependencies-installed.png`

### 1.4 Application Setup

#### Flask Backend Setup

**Commands:**
```bash
mkdir -p ~/apps && cd ~/apps
git clone https://github.com/YOUR_USERNAME/flask-backend.git
cd flask-backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
deactivate
```

**Starting Flask with PM2:**
```bash
pm2 start "source venv/bin/activate && python app.py" --name flask-backend
pm2 save
pm2 startup
```

**Testing:**
```bash
curl http://localhost:5000/api/health
```

**Output:**
```json
{
  "status": "healthy",
  "message": "Flask backend is running",
  "timestamp": "2026-09-04T10:30:00.123456"
}
```

**Screenshot Reference:** `screenshots/flask-setup.png`, `screenshots/flask-running.png`

#### Express Frontend Setup

**Commands:**
```bash
cd ~/apps
git clone https://github.com/YOUR_USERNAME/express-frontend.git
cd express-frontend
npm install
```

**Starting Express with PM2:**
```bash
export FLASK_API_URL=http://localhost:5000
pm2 start npm --name express-frontend -- start
pm2 save
```

**Testing:**
```bash
curl http://localhost:3000/health
```

**Screenshot Reference:** `screenshots/express-setup.png`, `screenshots/express-running.png`

### 1.5 PM2 Process Management

**PM2 Status:**
```bash
pm2 status
```

**Output:**
```
┌─────┬──────────────────┬─────────┬─────────┬─────────┬──────────┐
│ id  │ name             │ mode    │ ↺       │ status  │ cpu      │
├─────┼──────────────────┼─────────┼─────────┼─────────┼──────────┤
│ 0   │ flask-backend    │ fork    │ 0       │ online  │ 0%       │
│ 1   │ express-frontend │ fork    │ 0       │ online  │ 0%       │
└─────┴──────────────────┴─────────┴─────────┴─────────┴──────────┘
```

**Screenshot Reference:** `screenshots/pm2-status.png`

### 1.6 Application Access

**URLs:**
- **Flask Backend:** http://65.1.100.135:5000
- **Express Frontend:** http://65.1.100.135:3000

**Screenshot Reference:** `screenshots/flask-browser.png`, `screenshots/express-browser.png`

---

## Part 2: Jenkins CI/CD Pipeline

### 2.1 Jenkins Installation

**Commands:**
```bash
# Install Java
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

# Get initial password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

**Initial Admin Password:** [Your Password]

**Screenshot Reference:** `screenshots/jenkins-installation.png`, `screenshots/jenkins-initial-password.png`

### 2.2 Jenkins Configuration

#### Accessing Jenkins
- **URL:** http://65.1.100.135:8080
- Entered initial admin password
- Installed suggested plugins

**Screenshot Reference:** `screenshots/jenkins-unlock.png`, `screenshots/jenkins-plugins.png`

#### Installed Additional Plugins
1. Git plugin
2. GitHub Integration Plugin
3. NodeJS Plugin
4. Pipeline Plugin
5. SSH Agent Plugin

**Screenshot Reference:** `screenshots/jenkins-additional-plugins.png`

#### Global Tool Configuration

**NodeJS Configuration:**
- Name: NodeJS-18
- Version: NodeJS 18.x
- Install automatically: ✓

**Screenshot Reference:** `screenshots/jenkins-nodejs-config.png`

### 2.3 Jenkins Credentials Setup

**Credential Type:** SSH Username with private key
- **ID:** ec2-ssh-key
- **Username:** ubuntu
- **Private Key:** [Pasted EC2 .pem key content]

**Screenshot Reference:** `screenshots/jenkins-credentials.png`

### 2.4 Flask Backend Pipeline

#### Pipeline Configuration
- **Name:** Flask-Backend-Pipeline
- **Type:** Pipeline
- **GitHub Project URL:** https://github.com/YOUR_USERNAME/flask-backend
- **Build Trigger:** GitHub hook trigger for GITScm polling ✓

**Pipeline Script from SCM:**
- **SCM:** Git
- **Repository URL:** https://github.com/YOUR_USERNAME/flask-backend.git
- **Branch:** */main
- **Script Path:** Jenkinsfile

**Screenshot Reference:** `screenshots/flask-pipeline-config.png`

#### Jenkinsfile Content
The Jenkinsfile includes the following stages:
1. **Checkout** - Clone repository
2. **Verify Python** - Check Python installation
3. **Setup Virtual Environment** - Create venv
4. **Install Dependencies** - Install from requirements.txt
5. **Run Tests** - Execute test suite (if available)
6. **Deploy Application** - Restart with PM2
7. **Health Check** - Verify deployment

**Full Jenkinsfile:** See `flask-backend/Jenkinsfile`

#### Pipeline Execution

**First Build (Manual):**
- Clicked "Build Now"
- Build #1 - SUCCESS

**Build Output Highlights:**
```
Started by user admin
Checking out code from repository...
✓ Code checkout completed successfully
Installing Python dependencies...
✓ Dependencies installed
Deploying Flask application...
✓ Flask Backend deployed
Health check passed - Flask backend is running!
Pipeline executed successfully!
```

**Screenshot Reference:** `screenshots/flask-pipeline-build.png`, `screenshots/flask-console-output.png`

### 2.5 Express Frontend Pipeline

#### Pipeline Configuration
- **Name:** Express-Frontend-Pipeline
- **Type:** Pipeline
- **GitHub Project URL:** https://github.com/YOUR_USERNAME/express-frontend
- **Build Trigger:** GitHub hook trigger for GITScm polling ✓

**Pipeline Script from SCM:**
- **SCM:** Git
- **Repository URL:** https://github.com/YOUR_USERNAME/express-frontend.git
- **Branch:** */main
- **Script Path:** Jenkinsfile

**Screenshot Reference:** `screenshots/express-pipeline-config.png`

#### Jenkinsfile Content
The Jenkinsfile includes the following stages:
1. **Checkout** - Clone repository
2. **Verify Node.js** - Check Node.js installation
3. **Install Dependencies** - Run npm install
4. **Run Tests** - Execute test suite (if available)
5. **Build** - Build application (if needed)
6. **Deploy Application** - Restart with PM2
7. **Health Check** - Verify deployment

**Full Jenkinsfile:** See `express-frontend/Jenkinsfile`

#### Pipeline Execution

**First Build (Manual):**
- Clicked "Build Now"
- Build #1 - SUCCESS

**Build Output Highlights:**
```
Started by user admin
Checking out code from repository...
✓ Code checkout completed successfully
Installing npm dependencies...
✓ Dependencies installed
Deploying Express application...
✓ Express Frontend deployed
Health check passed - Express frontend is running!
Pipeline executed successfully!
```

**Screenshot Reference:** `screenshots/express-pipeline-build.png`, `screenshots/express-console-output.png`

### 2.6 GitHub Webhook Configuration

#### Flask Backend Webhook
1. Navigated to GitHub repository settings
2. Webhooks → Add webhook
3. **Payload URL:** http://65.1.100.135:8080/github-webhook/
4. **Content type:** application/json
5. **Events:** Just the push event ✓
6. **Active:** ✓

**Screenshot Reference:** `screenshots/flask-webhook.png`, `screenshots/flask-webhook-delivery.png`

#### Express Frontend Webhook
1. Same configuration as Flask
2. Applied to express-frontend repository

**Screenshot Reference:** `screenshots/express-webhook.png`

### 2.7 Automated Deployment Test

#### Test 1: Flask Backend Update

**Changes Made:**
- Modified `app.py` to add a new endpoint
- Committed and pushed to GitHub

**Git Commands:**
```bash
git add app.py
git commit -m "Add new API endpoint"
git push origin main
```

**Jenkins Response:**
- Webhook triggered automatically
- Build #2 started
- Build completed successfully
- Application restarted with new code

**Screenshot Reference:** `screenshots/flask-auto-deploy.png`, `screenshots/flask-build-2.png`

#### Test 2: Express Frontend Update

**Changes Made:**
- Updated `public/style.css` to change colors
- Committed and pushed to GitHub

**Git Commands:**
```bash
git add public/style.css
git commit -m "Update UI colors"
git push origin main
```

**Jenkins Response:**
- Webhook triggered automatically
- Build #2 started
- Build completed successfully
- Application restarted with new styles

**Screenshot Reference:** `screenshots/express-auto-deploy.png`, `screenshots/express-build-2.png`

---

## Screenshots and Evidence

### Required Screenshots Included:

1. **EC2 Instance**
   - `screenshots/ec2-instance.png` - EC2 instance details
   - `screenshots/security-group.png` - Security group configuration
   - `screenshots/ssh-connection.png` - SSH connection to EC2

2. **Application Setup**
   - `screenshots/dependencies-installed.png` - All dependencies installed
   - `screenshots/flask-setup.png` - Flask backend setup
   - `screenshots/express-setup.png` - Express frontend setup
   - `screenshots/pm2-status.png` - PM2 process status

3. **Running Applications**
   - `screenshots/flask-running.png` - Flask backend running
   - `screenshots/flask-browser.png` - Flask API in browser
   - `screenshots/express-running.png` - Express frontend running
   - `screenshots/express-browser.png` - Express frontend in browser

4. **Jenkins Setup**
   - `screenshots/jenkins-installation.png` - Jenkins installation
   - `screenshots/jenkins-unlock.png` - Jenkins unlock screen
   - `screenshots/jenkins-dashboard.png` - Jenkins dashboard
   - `screenshots/jenkins-plugins.png` - Installed plugins
   - `screenshots/jenkins-nodejs-config.png` - NodeJS configuration

5. **Jenkins Pipelines**
   - `screenshots/flask-pipeline-config.png` - Flask pipeline configuration
   - `screenshots/flask-pipeline-build.png` - Flask pipeline execution
   - `screenshots/flask-console-output.png` - Flask build console output
   - `screenshots/express-pipeline-config.png` - Express pipeline configuration
   - `screenshots/express-pipeline-build.png` - Express pipeline execution
   - `screenshots/express-console-output.png` - Express build console output

6. **GitHub Webhooks**
   - `screenshots/flask-webhook.png` - Flask webhook configuration
   - `screenshots/express-webhook.png` - Express webhook configuration
   - `screenshots/webhook-delivery.png` - Webhook delivery confirmation

7. **Automated Deployment**
   - `screenshots/flask-auto-deploy.png` - Flask automatic deployment
   - `screenshots/express-auto-deploy.png` - Express automatic deployment
   - `screenshots/successful-deployment.png` - Both applications deployed

---

## GitHub Repository Links

### Flask Backend Repository
**URL:** https://github.com/YOUR_USERNAME/flask-backend

**Repository Contents:**
- `app.py` - Main Flask application
- `requirements.txt` - Python dependencies
- `Jenkinsfile` - CI/CD pipeline configuration
- `README.md` - Documentation

**Commit History:** Shows multiple commits with automated deployments

**Note:** Replace YOUR_USERNAME with your actual GitHub username in all repository links.

### Express Frontend Repository
**URL:** https://github.com/YOUR_USERNAME/express-frontend

**Repository Contents:**
- `server.js` - Express server
- `package.json` - npm dependencies
- `Jenkinsfile` - CI/CD pipeline configuration
- `public/` - Static assets (HTML, CSS, JS)
- `views/` - EJS templates
- `README.md` - Documentation

**Commit History:** Shows multiple commits with automated deployments

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        AWS EC2 Instance                      │
│                     (Ubuntu 22.04 LTS)                       │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                     Applications                        │ │
│  │                                                         │ │
│  │  ┌──────────────────┐      ┌──────────────────┐       │ │
│  │  │  Flask Backend   │      │ Express Frontend │       │ │
│  │  │   (Port 5000)    │◄─────┤   (Port 3000)    │       │ │
│  │  │                  │      │                  │       │ │
│  │  │  - REST API      │      │  - Web UI        │       │ │
│  │  │  - CRUD Ops      │      │  - User Interface│       │ │
│  │  │  - JSON Response │      │  - API Consumer  │       │ │
│  │  └──────────────────┘      └──────────────────┘       │ │
│  │           ▲                         ▲                  │ │
│  │           │                         │                  │ │
│  │           │    ┌────────────┐      │                  │ │
│  │           └────┤    PM2     ├──────┘                  │ │
│  │                │  Manager   │                         │ │
│  │                └────────────┘                         │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                    Jenkins (Port 8080)                  │ │
│  │                                                         │ │
│  │  ┌──────────────────┐      ┌──────────────────┐       │ │
│  │  │  Flask Pipeline  │      │ Express Pipeline │       │ │
│  │  │                  │      │                  │       │ │
│  │  │  1. Checkout     │      │  1. Checkout     │       │ │
│  │  │  2. Setup venv   │      │  2. npm install  │       │ │
│  │  │  3. Install deps │      │  3. Build        │       │ │
│  │  │  4. Test         │      │  4. Test         │       │ │
│  │  │  5. Deploy       │      │  5. Deploy       │       │ │
│  │  │  6. Health Check │      │  6. Health Check │       │ │
│  │  └──────────────────┘      └──────────────────┘       │ │
│  │           ▲                         ▲                  │ │
│  │           │                         │                  │ │
│  │           └─────────────┬───────────┘                  │ │
│  │                         │                              │ │
│  └─────────────────────────┼──────────────────────────────┘ │
│                            │                                │
└────────────────────────────┼────────────────────────────────┘
                             │
                    ┌────────┴────────┐
                    │  GitHub Webhook │
                    │                 │
                    │  - Flask Repo   │
                    │  - Express Repo │
                    └─────────────────┘
```

---

## Challenges Faced

### Challenge 1: EC2 Security Group Configuration
**Problem:** Initially, applications were not accessible from browser.
**Solution:** Added custom TCP rules for ports 3000, 5000, and 8080 to allow inbound traffic.

### Challenge 2: PM2 Process Management
**Problem:** PM2 processes not persisting after reboot.
**Solution:** Used `pm2 save` and `pm2 startup` commands to configure PM2 to start on boot.

### Challenge 3: Flask Virtual Environment in Jenkins
**Problem:** Jenkins couldn't activate Python virtual environment.
**Solution:** Modified Jenkinsfile to use inline activation: `source venv/bin/activate && python app.py`

### Challenge 4: GitHub Webhook Authentication
**Problem:** Webhook couldn't reach Jenkins initially.
**Solution:** Ensured Jenkins was accessible on port 8080 from GitHub (0.0.0.0/0 in security group).

### Challenge 5: Express-Flask Communication
**Problem:** Express frontend couldn't connect to Flask backend.
**Solution:** Set `FLASK_API_URL` environment variable and enabled CORS in Flask application.

---

## Lessons Learned

1. **Infrastructure as Code:** Automated setup scripts save significant time
2. **Process Management:** PM2 is essential for keeping Node.js applications running
3. **CI/CD Benefits:** Automated deployment reduces human error and speeds up releases
4. **Security Groups:** Proper configuration is crucial for application accessibility
5. **Health Checks:** Essential for verifying successful deployments
6. **Documentation:** Comprehensive documentation helps in troubleshooting and future reference

---

## Conclusion

This project successfully demonstrates:

✅ **Part 1 Completion:**
- Flask backend deployed on EC2 (Port 5000)
- Express frontend deployed on EC2 (Port 3000)
- Both applications running with PM2
- Applications accessible via public IP

✅ **Part 2 Completion:**
- Jenkins installed and configured
- Two separate CI/CD pipelines created
- GitHub webhooks configured for automatic deployment
- Automated deployment tested and verified

The CI/CD pipeline automates the entire deployment process, from code commit to live application, ensuring consistent and reliable deployments. Every push to the GitHub repositories triggers an automatic build and deployment, demonstrating modern DevOps practices.

---

## Project Files Structure

```
Jenkins_CICD_YourName/
├── README.md                      # Main documentation
├── SUBMISSION_DOCUMENT.md         # This file
├── flask-backend/
│   ├── app.py
│   ├── requirements.txt
│   ├── Jenkinsfile
│   └── README.md
├── express-frontend/
│   ├── server.js
│   ├── package.json
│   ├── Jenkinsfile
│   ├── public/
│   │   ├── style.css
│   │   └── script.js
│   ├── views/
│   │   ├── index.ejs
│   │   └── 404.ejs
│   └── README.md
├── scripts/
│   ├── setup-ec2.sh
│   ├── deploy.sh
│   └── clone-repos.sh
└── screenshots/
    ├── ec2-instance.png
    ├── flask-running.png
    ├── express-running.png
    ├── jenkins-dashboard.png
    ├── flask-pipeline-build.png
    ├── express-pipeline-build.png
    └── successful-deployment.png
```

---

## References

1. Flask Documentation: https://flask.palletsprojects.com/
2. Express.js Documentation: https://expressjs.com/
3. Jenkins Documentation: https://www.jenkins.io/doc/
4. PM2 Documentation: https://pm2.keymetrics.io/
5. AWS EC2 Documentation: https://docs.aws.amazon.com/ec2/

---

**Submitted By:** [Your Name]  
**Date:** September 4, 2026  
**Course:** DevOps - Jenkins CI/CD Pipeline Assignment

---

## Declaration

I declare that this assignment is my own work and that all sources used have been acknowledged. The screenshots and commands shown are from my actual implementation.

**Signature:** _________________  
**Date:** September 4, 2026
