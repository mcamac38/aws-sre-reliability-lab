# Phase 1D Auto Scaling Group Deployment

## Summary

Updated the EC2 web service so instances are launched and managed by an Auto Scaling Group instead of a standalone EC2 resource.

## Architecture

Internet → Application Load Balancer → Auto Scaling Group → EC2 instances → Nginx

## Resources Added

- EC2 Launch Template
- Auto Scaling Group
- ASG-based CloudWatch CPU alarm

## Resources Removed

- Standalone Terraform-managed EC2 instance
- Manual target group attachment

## Validation

- Terraform plan reviewed before apply.
- Terraform apply completed successfully.
- ALB URL returned HTTP 200 OK.
- Auto Scaling Group launched the desired number of instances.
- ALB target group reported healthy targets.

## SRE Lesson

An Auto Scaling Group improves reliability by maintaining desired capacity and replacing unhealthy instances. This is a foundation for failure recovery testing.