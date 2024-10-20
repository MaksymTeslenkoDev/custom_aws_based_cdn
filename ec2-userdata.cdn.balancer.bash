#!/bin/bash

# Update package lists
sudo apt-get update

# Install Docker
sudo apt-get install -y docker.io

# Ensure Docker starts on boot
sudo systemctl start docker
sudo systemctl enable docker

# Pull your Docker image from Docker Hub
sudo docker pull devmaksdev/nginx-reverse-proxy-cache:amd64

# verify that provided public ip's point to existed reverse-cache-proxy servers
docker run -d -p 80:80 --name cdn-lb -e CACHE_SERVERS="server 13.51.201.229; server 35.180.16.210;" devmaksdev/cdn-least-con-lb-image:latest
