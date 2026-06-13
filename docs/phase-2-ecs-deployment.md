# Phase 2 ECS Fargate Deployment

## Summary

Phase 2 converted the lab from an EC2-based deployment model to a container-based deployment model using Docker, Amazon ECR, Amazon ECS, AWS Fargate, an Application Load Balancer, and CloudWatch Logs.

The goal was to package a simple Flask application into a Docker image, store that image in Amazon ECR, define how ECS should run the container, and deploy the application as a highly available ECS Fargate service behind an Application Load Balancer.

## Architecture

```text
User Browser
    ↓
Application Load Balancer
    ↓
ALB Target Group
    ↓
ECS Fargate Service
    ↓
Running ECS Tasks
    ↓
Docker container running Flask on port 8080
    ↓
CloudWatch Logs
```

## Phase 2A: Dockerized Flask Application

A small Flask web application was created under:

```text
app/ecs-web
```

The application includes:

- A `/` route that returns a basic HTML page.
- A `/health` route that returns a JSON health response.
- A `/version` route that returns the current application version.
- A Dockerfile that packages the application into a container image.

The local Docker image was built and tested successfully before pushing it to AWS.

Local test result:

```text
HTTP 200 OK
```

## Phase 2B: Amazon ECR Repository

An Amazon ECR repository named `sre-ecs-web` was created using Terraform.

The Docker image was tagged and pushed to ECR as:

```text
sre-ecs-web:v1
```

ECR acts as the private container image registry for the deployment. ECS uses this repository to pull the application image whenever it starts or replaces a task.

During this phase, Docker login to ECR initially failed in PowerShell with a `400 Bad Request` error. The issue was resolved by running the ECR Docker login command from Command Prompt instead of PowerShell.

## Phase 2C: ECS Cluster and Task Definition

A separate Terraform environment was created for ECS:

```text
terraform/environments/phase2-ecs
```

This kept the ECS work separate from the earlier Phase 1 EC2, ALB, and Auto Scaling Group infrastructure.

The following ECS foundation resources were created:

- ECS cluster
- CloudWatch log group
- ECS task execution IAM role
- IAM policy attachment for ECS task execution
- ECS task definition

The ECS task definition describes how to run the container, including:

- Container image from ECR
- Container port `8080`
- CPU and memory settings
- Environment variable `APP_VERSION=v1`
- CloudWatch log configuration
- Fargate compatibility
- `awsvpc` network mode

The task definition is the deployment recipe for the container. It does not run the application by itself; it only tells ECS how the task should be launched.

## Phase 2D: ECS Fargate Service Behind ALB

The ECS service was then created to actually run and maintain the application.

The following resources were added:

- Default VPC lookup
- Default subnet lookup
- ALB security group
- ECS task security group
- Application Load Balancer
- ALB target group
- HTTP listener
- ECS Fargate service

The ECS service was configured with:

```text
desired_count = 2
launch_type   = FARGATE
```

This tells ECS to keep two copies of the application running. If one task fails or is stopped, ECS should start a replacement task.

The ALB forwards public HTTP traffic on port `80` to the ECS tasks on container port `8080`.

The target group uses the `/health` endpoint to determine whether each ECS task is healthy.

## Security Group Design

Two security groups were used:

```text
Internet → ALB security group → ECS task security group → Container port 8080
```

The ALB security group allows inbound HTTP traffic from the internet on port `80`.

The ECS task security group allows inbound traffic on port `8080` only from the ALB security group.

This prevents the ECS tasks from being directly exposed to the internet.

## Validation

After deployment, the ECS service was verified with AWS CLI commands.

The service showed:

```text
Desired: 2
Running: 2
Pending: 0
Status: ACTIVE
```

The ALB target group showed both targets as healthy.

The application was reachable through the ALB URL and returned:

```text
HTTP 200 OK
```

The `/health` endpoint also returned a healthy JSON response.

## Troubleshooting Notes

Several issues were encountered and resolved during this phase:

- Docker login to ECR failed in PowerShell with `400 Bad Request`.
  - Resolved by running the ECR Docker login command in Command Prompt.
- IAM role creation failed due to a typo:
  - Incorrect: `sts.AssumeRole`
  - Correct: `sts:AssumeRole`
- Terraform attempted to use a nonexistent provider named `hashicorp/aws-lb`.
  - Cause: resource names were written with dashes instead of underscores.
  - Incorrect: `aws-lb`
  - Correct: `aws_lb`
- ALB creation failed because the security group reference was quoted.
  - Incorrect: `security_groups = ["aws_security_group.alb.id"]`
  - Correct: `security_groups = [aws_security_group.alb.id]`
- ECS service configuration required the container name in the service load balancer block to exactly match the container name in the task definition.

## Result

Phase 2 successfully deployed a containerized Flask application to AWS using ECS Fargate.

The final deployment includes:

- Dockerized Flask app
- ECR image repository
- ECS cluster
- ECS task definition
- ECS Fargate service
- Application Load Balancer
- Target group health checks
- CloudWatch logging
- Two running healthy tasks

## SRE Lesson

Phase 2 demonstrated the container-based version of the reliability pattern built in Phase 1.

Instead of managing EC2 instances directly, the application is packaged as a Docker image and ECS maintains the desired number of running tasks. The ALB routes traffic only to healthy tasks, while CloudWatch provides logs for troubleshooting.

This setup is closer to modern production deployment patterns where services are containerized, deployed through image registries, and maintained by orchestration platforms.

## Commands Used

The following commands were used during Phase 2:

```text
cd

mkdir

notepad

docker build

docker run

docker login

docker tag

docker push

Invoke-WebRequest

aws sso login

aws sts get-caller-identity

aws ecr describe-repositories

aws ecr get-authorization-token

aws ecr get-login-password

aws ecr describe-images

aws ecs describe-clusters

aws ecs describe-task-definition

aws ecs describe-services

aws ecs list-tasks

aws ecs stop-task

aws elbv2 describe-target-health

terraform fmt

terraform init

terraform validate

terraform plan

terraform apply

terraform output

terraform providers

Select-String

git status

git add

git commit

git push

git push --set-upstream
```
