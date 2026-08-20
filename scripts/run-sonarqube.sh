#!/usr/bin/env bash
# Run SonarQube server as a Docker container (dev/demo).
set -euo pipefail
docker run -d --name sonarqube --restart unless-stopped \
  -p 9000:9000 sonarqube:lts-community
echo ">> SonarQube starting on http://<EC2_PUBLIC_IP>:9000  (default login admin/admin)"
