# 🚀 Flask + Express Full-Stack Deployment with Terraform (AWS)

Deploy a **Flask backend** and **Express (Node.js) frontend** on **separate EC2 instances** using **Terraform**, running in **AWS ap-south-1** with **t3.micro** instances.

This project is ideal for:

* Learning real-world Terraform
* Understanding frontend ↔ backend separation
* Simple production-style AWS deployments

---

## 🧱 Architecture Overview

```
                🌐 Internet
                     |
        ┌────────────┴────────────┐
        |                         |
 ┌──────▼──────┐           ┌──────▼──────┐
 | Frontend SG |           | Backend SG  |
 | 3000, 22    |           | 5000, 22    |
 └──────┬──────┘           └──────┬──────┘
        |                         |
 ┌──────▼──────┐           ┌──────▼──────┐
 | EC2 (Node)  |           | EC2 (Flask) |
 | Express App |           | Flask API   |
 | t3.micro    |           | t3.micro    |
 └─────────────┘           └─────────────┘
            \               /
             └────── VPC ───┘
               10.0.0.0/16
```

---

## ✅ What Terraform Creates

* Custom **VPC**
* Public subnets
* Security Groups
* 2 EC2 instances:

  * **Frontend** → Express (Port `3000`)
  * **Backend** → Flask (Port `5000`)
* Automatic app setup using **user_data scripts**

---

## 📦 Prerequisites

Make sure you have the following before starting:

* AWS account
* AWS CLI configured

  ```bash
  aws configure
  ```
* Terraform `v1.0+`

  ```bash
  terraform -version
  ```
* **EC2 Key Pair** (created in AWS Console)

  * Download `.pem`
  * Keep it safe (used for SSH)

---

## 📁 Project Structure

```
.
├── backend/
│   ├── app.py
│   └── requirements.txt
│
├── frontend/
│   ├── server.js
│   ├── package.json
│   └── public/
│       └── index.html
│
└── terraform/
    ├── main.tf
    ├── variables.tf
    ├── vpc.tf
    ├── security_groups.tf
    ├── ec2_backend.tf
    ├── ec2_frontend.tf
    ├── outputs.tf
    ├── terraform.tfvars
    └── user_data_scripts/
        ├── backend_setup.sh
        └── frontend_setup.sh
```

---

## ⚙️ Terraform Configuration

### `terraform.tfvars`

Only **these values are required** 👇

```hcl
aws_region   = "ap-south-1"
instance_type = "t3.micro"

key_name = "your-ec2-keypair-name"

# Your public IP (for SSH access)
# Run: curl ifconfig.me
my_ip = "YOUR_IP/32"
```

---

## 🚀 Deploy Infrastructure

From the `terraform` directory:

```bash
terraform init
terraform plan
terraform apply
```

⏳ Deployment time: **~5 minutes**

---

## 🌍 Access the Application

After apply completes:

```bash
terraform output
```

Example output:

```
frontend_url = http://13.xxx.xxx.xxx:3000
backend_url  = http://15.xxx.xxx.xxx:5000
```

### Open in browser

* Frontend → `http://FRONTEND_IP:3000`
* Backend health → `http://BACKEND_IP:5000/api/health`

---

## 🔍 Verify Backend API

```bash
curl http://BACKEND_IP:5000/api/health
```

Expected:

```json
{
  "status": "healthy",
  "service": "flask-backend"
}
```

---

## 🔐 Security Notes (Dev Setup)

* SSH (`22`) allowed **only from your IP**
* Backend port `5000` open for testing
* Both instances are in **public subnets**

> ⚠️ For production, move backend to private subnet and use an ALB.

---

## 🧹 Destroy Resources (Important)

To avoid AWS charges:

```bash
terraform destroy
```

This removes **everything** created by Terraform.

