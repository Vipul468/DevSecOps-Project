#!/usr/bin/env bash
# Install the CI toolchain on an Ubuntu 22.04 EC2 (the Jenkins node).
# Run as a user with sudo.  Tested on Ubuntu 22.04.
set -euo pipefail

echo ">> System update"
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y curl unzip gnupg ca-certificates apt-transport-https software-properties-common

echo ">> Java 17 (for Jenkins & SonarQube scanner)"
sudo apt-get install -y openjdk-17-jdk

echo ">> Docker"
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker "$USER" || true
sudo usermod -aG docker jenkins || true

echo ">> AWS CLI v2"
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip -q awscliv2.zip && sudo ./aws/install --update && rm -rf aws awscliv2.zip

echo ">> kubectl"
curl -sLO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -m 0755 kubectl /usr/local/bin/kubectl && rm kubectl

echo ">> eksctl"
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

echo ">> Terraform"
wget -qO- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update -y && sudo apt-get install -y terraform

echo ">> Helm"
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo ">> Trivy"
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin

echo ">> Node.js 18 + sonar-scanner CLI"
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
curl -sL https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip -o ss.zip
sudo unzip -q ss.zip -d /opt && sudo ln -sf /opt/sonar-scanner-*/bin/sonar-scanner /usr/local/bin/sonar-scanner && rm ss.zip

echo ">> ArgoCD CLI"
curl -sSL -o /tmp/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 0555 /tmp/argocd /usr/local/bin/argocd && rm /tmp/argocd

echo ">> DONE.  Log out & back in so docker group applies."
