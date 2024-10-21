#!/bin/bash
# Update the instance
sudo apt-get update -y

# Install Docker
sudo apt-get install -y docker.io

# Enable Docker service to start on boot
sudo systemctl enable docker
sudo systemctl start docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify Docker Compose installation
docker-compose --version

# Create a directory for your Docker setup
mkdir -p /home/ubuntu/docker-setup
cd /home/ubuntu/docker-setup

# Create the docker-compose.yml file
cat <<EOF > /home/ubuntu/docker-setup/docker-compose.yml
version: '3'
services:
  cache-proxy-1:
    image: devmaksdev/nginx-reverse-proxy-cache:amd64
    container_name: cache-proxy-1
    environment:
      S3_BUCKET_NAME: www.my.githubresumebuilder.cloud.s3-website-us-east-1.amazonaws.com
    ports:
      - "8081:80"
    restart: always

  cache-proxy-2:
    image: devmaksdev/nginx-reverse-proxy-cache:amd64
    container_name: cache-proxy-2
    environment:
      S3_BUCKET_NAME: www.my.githubresumebuilder.cloud.s3-website-us-east-1.amazonaws.com
    ports:
      - "8082:80"
    restart: always
  
  cdn-lb:
    image: devmaksdev/cdn-least-con-lb-image:latest
    container_name: cdn-lb
    environment:
      - CACHE_SERVERS=server cache-proxy-1; server cache-proxy-2;
    ports:
      - "80:80"
    depends_on:
      - cache-proxy-1
      - cache-proxy-2
    restart: always
EOF

# Change directory permissions
sudo chown -R ubuntu:ubuntu /home/ubuntu/docker-setup

# Run docker-compose to pull images and start the services
cd /home/ubuntu/docker-setup
sudo docker-compose up -d
