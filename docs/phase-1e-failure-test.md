# Phase 1E Failure Test

## Summary

Performed a controlled failure test by terminating one EC2 instance managed by the Auto Scaling Group.

## Architecture

Internet → Application Load Balancer → Auto Scaling Group → EC2 instances → Nginx

## Failure Simulated

One EC2 instance in the Auto Scaling Group was manually terminated using the AWS CLI.

## Expected Behavior

The Auto Scaling Group should maintain desired capacity by replacing the terminated instance. The Application Load Balancer should continue routing traffic to healthy targets.

## Validation

- One instance entered `Terminating` state.
- Remaining instances stayed `Healthy` and `InService`.
- Target group showed healthy targets.
- ALB URL continued returning HTTP `200 OK`.

## Result

The system recovered as expected. The Auto Scaling Group maintained desired capacity, and the Application Load Balancer continued serving traffic through healthy targets.

## SRE Lesson

Auto Scaling Groups improve reliability by replacing failed instances automatically. Application Load Balancers help maintain availability by routing traffic only to healthy targets.