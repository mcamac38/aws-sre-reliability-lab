# Phase 1 EC2 Deployment

## Summary

Deployed a basic EC2-hosted Nginx web server using Terraform with basic HTML

## Resources Created

- EC2 instance: `sre-lab-dev-web`
- Security group: `sre-lab-dev-web-sg`
- Inbound HTTP access on port 80
- Amazon Linux 2023 AMI retrieved through AWS SSM Parameter Store
- Nginx installed through EC2 user data

## Validation

Terraform commands used:

With PowerShell:

terraform fmt -recursive
terraform validate
terraform plan -out="phase1-ec2.tfplan"
terraform apply
terraform state list
terraform output