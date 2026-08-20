#!/usr/bin/env bash
# Install Jenkins (LTS) on Ubuntu 22.04.  Run after install-tools.sh.
set -euo pipefail
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y && sudo apt-get install -y jenkins
sudo systemctl enable jenkins && sudo systemctl start jenkins
echo ">> Jenkins is on http://<EC2_PUBLIC_IP>:8080"
echo ">> Initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
