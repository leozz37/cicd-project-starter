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

# login DockerHub
docker login --username $DOCKER_HUB_USER --password $DOCKER_HUB_PASS

# Push Dockerfile to DockerHub
docker build -t $IMAGE_REPO_URL .
docker tag $IMAGE_REPO_URL:latest $IMAGE_REPO_URL:latest
docker push $IMAGE_REPO_URL:latest

# Deleting ECS Task
TASK_ID=`aws ecs list-tasks --desired-status "RUNNING" --cluster $ECS_CLUSTER_NAME | grep arn | sed 's/[ "]//g'`
aws ecs stop-task --cluster $ECS_CLUSTER_NAME --task $TASK_ID --reason "Deploy" > /dev/null

# Creating ECS Task
ecs-cli compose --project-name $ECS_CLUSTER_NAME --task-role-arn arn:aws:iam::816898588873:role/ecsTaskExecutionRole \ 
    service create --cluster-config $ECS_CLUSTER_NAME

exit 0