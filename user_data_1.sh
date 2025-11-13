#!/bin/bash
# Update and install dependencies
sudo yum update -y
sudo yum install -y java-17-amazon-corretto awscli

# Create app directory
sudo mkdir -p /opt/app
cd /opt/app

# Download jar from your existing S3 bucket
aws s3 cp s3://jar5/hellomvc-0.0.1-SNAPSHOT.jar /opt/app/app.jar

# Create systemd service for the app
sudo bash -c 'cat > /etc/systemd/system/app.service <<EOF
[Unit]
Description=Spring Boot Application
After=network.target

[Service]
User=ec2-user
ExecStart=/usr/bin/java -jar /opt/app/app.jar --server.port=8080
SuccessExitStatus=143
Restart=always
RestartSec=10
StandardOutput=file:/var/log/app.log
StandardError=file:/var/log/app-error.log

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl enable app
sudo systemctl start app
