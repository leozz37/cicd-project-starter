#!/bin/bash

# Installing AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Installing ECS CLI
sudo curl -Lo /usr/local/bin/ecs-cli https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-amd64-latest
gpg --keyserver hkp://keys.gnupg.net --recv BCE9D9A42D51784F
sudo chmod +x /usr/local/bin/ecs-cli

# AWS Login
ecs-cli configure profile --profile-name profile --access-key $AWS_ACCESS_KEY_ID --secret-key $AWS_SECRET_ACCESS_KEY

############################# USING ECR
# Check your AWS Console and get the URI created for your repository
# Go to Services > ECR and your URI will be there
# You have to change the docker compose image, to the URI
aws ecr create-repository --repository-name $ECR_REPOSITORY
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URI

############################# USING ECR
docker build -t $IMAGE_REPO_URL .
docker tag $IMAGE_REPO_URL:latest $IMAGE_REPO_URL:latest
docker push $IMAGE_REPO_URL:latest

# Uploading image to ECR
docker tag leozz37/$ECR_REPOSITORY:latest $ECR_PASS
docker push $ECR_PASS

# Setting Up Cluster
ecs-cli configure --cluster $AWS_CLUSTER --default-launch-type EC2 --region $AWS_DEFAULT_REGION --config-name $AWS_CLUSTER
ecs-cli up --capability-iam-size 1 --instance-type t2.micro --cluster-config $AWS_CLUSTER --ecs-profile profile --force
ecs-cli compose --project-name $AWS_CLUSTER --task-role-arn arn:aws:iam::816898588873:role/ecsTaskExecutionRole service create \ 
    --ecs-profile profile --cluster-config $AWS_CLUSTER
