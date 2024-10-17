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

docker run -d -p 80:80 --name nginx-cache-server -e S3_BUCKET_NAME="www.my.githubresumebuilder.cloud.s3-website-us-east-1.amazonaws.com" devmaksdev/nginx-cache-purge:latest
