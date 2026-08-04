# Phase 2E ECS Failure Recovery Test

## Goal

Validate that the ECS Fargate service can recover from a failed task while the application remains available through the Application Load Balancer.

## Test Steps

1. Verified the ECS service had desired count 2, running count 2, and pending count 0.
2. Verified both ALB target group targets were healthy.
3. Stopped one running ECS task intentionally using `aws ecs stop-task`.
4. Observed the ECS service enter a temporary recovery state with running count 1 and pending count 1.
5. Observed the stopped target enter the ALB target group `draining` state.
6. Verified the remaining healthy target continued serving traffic.
7. Confirmed ECS launched a replacement task.
8. Confirmed the service returned to desired count 2, running count 2, and pending count 0.
9. Confirmed both ALB targets returned to healthy.

## Result

The ECS service successfully replaced the stopped task and restored the service to the desired state. The ALB continued routing traffic to healthy targets during the recovery process.

## SRE Lesson

ECS services maintain desired state by replacing failed or stopped tasks. When combined with an ALB target group and health checks, ECS can remove unhealthy tasks from traffic and restore service capacity automatically.