#!/bin/bash

# Install Java OpenJDK11
sudo apt update
java -version
sudo apt-get install openjdk-11-jdk -y
java -version

# Install Jenkins
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update && sudo apt upgrade -y
sudo apt-get install jenkins -y

# Start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Find Initial Password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword