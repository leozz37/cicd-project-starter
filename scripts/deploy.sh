#!/bin/bash

# login DockerHub
docker login --username $DOCKER_HUB_USER --password $DOCKER_HUB_PASS

# Push Dockerfile to DockerHub
docker-compose build --pull
docker-compose push

# Installing AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip > /dev/null
sudo ./aws/install

# Login AWS
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws configure set region $AWS_DEFAULT_REGION

# Update service
aws ecs update-service --cluster $ECS_CLUSTER_NAME --service $ECS_SERVICE_NAME --force-new-deployment