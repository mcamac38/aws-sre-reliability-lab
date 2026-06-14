variable "aws_region" {
  description = "AWS region for Phase 3 EKS resources"
  type        = string
  default     = "us-east-2"
}

variable "aws_profile" {
  description = "AWS CLI profile used by Terraform."
  type        = string
  default     = "terraform_learn"
}

variable "project_name" {
  description = "Base name used for Phase 3 EKS resources."
  type        = string
  default     = "sre-lab"
}

variable "environment" {
  description = "Environment name for Phase 3"
  type        = string
  default     = "phase3-eks"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.34"
}

variable "vpc_cidr" {
  description = "CIDR block for the Phase 3 EKS VPC."
  type        = string
  default     = "10.30.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
  default = [
    "10.30.0.0/20",
    "10.30.16.0/20"
  ]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets."
  type        = list(string)
  default = [
    "10.30.32.0/20",
    "10.30.48.0/20"
  ]
}