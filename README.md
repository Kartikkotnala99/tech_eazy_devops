# tech_easy_devops
#  Terraform AWS Web Application Deployment

This project automates the deployment of a simple web application on AWS EC2 using **Terraform** and **user data scripts**.  
It provisions infrastructure, installs dependencies, deploys a Java web app, and hosts a confirmation message on Apache/Nginx.

---

##  Project Structure
.
├── main.tf # Terraform configuration file
├── variables.tf # Variable definitions (like key pair)
├── user_data.sh # Bash script to configure EC2 instance automatically
└── README.md # Instructions to run the project

---

## What This Terraform Setup Does

- Creates a **Security Group** allowing HTTP (80) and SSH (22)
- Launches an **EC2 Instance** in **ap-south-1 (Mumbai)** region  
- Executes a **user_data.sh** script to:
  - Install Java, Maven, Git, and Apache
  - Clone the sample DevOps project from GitHub  
  - Build the project using Maven  
  - Run the `.jar` application in the background  
  - Display a success message at the instance’s public IP via Apache web server

---

##  Prerequisites

Make sure you have the following installed locally:

- An **IAM User** with:
  - Programmatic Access (Access Key + Secret Key)
  - Permissions: `AmazonEC2FullAccess`, `AmazonVPCFullAccess`
- A valid **key pair** created in your AWS account (e.g., `my-key.pem`)
- Your AWS CLI configured:
  ```bash
  aws configure

Step 1: Clone the Repository
git clone https://github.com/Kartikkotnala99/tech_easy_devops.git
cd tech_easy_devops
git checkout ec2-terraform

Step 2: Initialize Terraform
terraform init

Step 3: Validate and Plan
terraform validate
terraform plan


This shows what Terraform will create (EC2 instance, security group, etc.).

Step 4: Apply the Configuration
terraform apply -auto-approve

Terraform will:

Create AWS resources

Execute user_data.sh automatically on the new EC2 instance

Step 5: Verify Deployment

Go to your AWS Console → EC2 → Copy your instance Public IPv4 DNS or Public IP

Paste it in your browser:

http://<your-public-ip>/


You should see:

App Deployed Successfully via Terraform
