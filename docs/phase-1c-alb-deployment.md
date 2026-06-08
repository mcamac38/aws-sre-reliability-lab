# Phase 1C Application Load Balancer Deployment

## Summary

Updated the EC2 web server architecture to place an Application Load Balancer in front of the instance.

## Architecture

Internet → Application Load Balancer → EC2 instance → Nginx

## Resources Added

- Application Load Balancer
- ALB security group
- Target group
- Target group attachment
- HTTP listener on port 80

## Security Group Change

The EC2 instance no longer accepts HTTP directly from the internet. It accepts HTTP traffic from the ALB security group.

## Validation

- `terraform plan` reviewed before apply.
- `terraform apply` completed successfully.
- `Invoke-WebRequest` to the ALB URL returned HTTP 200 OK.
- Target group health check confirmed the EC2 instance is healthy.

## SRE Lesson

A load balancer provides a stable public entry point and health-checking layer in front of compute resources. This prepares the architecture for future Auto Scaling and failure recovery testing.