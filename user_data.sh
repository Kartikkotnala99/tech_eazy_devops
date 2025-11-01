#!/bin/bash

sudo apt update -y
sudo apt install -y git openjdk-21-jdk maven apache2

java -version

# Set environment variable for stage
STAGE=${STAGE:-dev}
echo "Running in ${STAGE} environment" | sudo tee /home/ubuntu/environment.txt

cd /home/ubuntu
git clone https://github.com/Trainings-TechEazy/test-repo-for-devops.git
cd test-repo-for-devops
mvn clean package

nohup java -jar target/techeazy-devops-0.0.1-SNAPSHOT.jar > app.log 2>&1 &

echo "<h1>App Deployed Successfully via Terraform </h1>" | sudo tee /var/www/html/index.html
sudo systemctl restart apache2

#Automatic shutdown after 1 hour
(sleep 3600 && sudo shutdown -h now) &



