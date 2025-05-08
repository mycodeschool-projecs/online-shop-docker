#!/usr/bin/env bash
set -euo pipefail

echo "=== Updating apt and removing old Docker versions (if any) ==="
sudo apt-get update -y
sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

echo "=== Installing required packages ==="
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo "=== Adding Docker’s official GPG key ==="
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "=== Setting up the Docker repository ==="
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "=== Installing Docker Engine, buildx plugin, and Docker Compose plugin ==="
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "=== Starting and enabling Docker service ==="
sudo systemctl enable docker
sudo systemctl start docker

echo "=== Adding current user to 'docker' group (so you can run docker without sudo) ==="
sudo usermod -aG docker "$USER"

echo "=== Docker Versions ==="
docker --version
docker compose version

echo "=== Done! ==="
echo "Log out and log back in (or run 'newgrp docker') for group changes to take effect."
