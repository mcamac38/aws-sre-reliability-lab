packer {
  required_plugins {
    amazon = {
	  version = ">= 1.3.0"
	  source = "github.com/hashicorp/amazon"
	}
  }
}

variable "aws_region" {
  type = string
  default = "us-east-2"
}

variable "aws_profile" {
  type = string
  default = "terraform_learn"
}

variable "kubernetes_version" {
  type = string
  default = "1.34"
}

variable "source_ami_id" {
  type = string
  description = "Base EKS-optimized AL2023 AMI ID."
}

variable "instance_type" {
  type = string
  default = "t3.small"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  ami_name = "sre-lab-eks-node-al2023-${var.kubernetes_version}-${local.timestamp}"
}

source "amazon-ebs" "eks_node" {
  region = var.aws_region
  profile = var.aws_profile
  source_ami = var.source_ami_id
  instance_type = var.instance_type
  ssh_username = "ec2-user"
  
  ami_name = local.ami_name
  ami_description = "Custom EKS AL2023 worker node AMI for the SRE reliability lab."
  
  tags = {
    Name = local.ami_name
	Project = "sre-lab"
	Phase = "3"
	BuiltBy = "Packer"
	Purpose = "EKS worker node AMI"
	KubernetesVersion = var.kubernetes_version
	BaseAMI = var.source_ami_id
  }
  
  run_tags = {
    Name = "packer-sre-lab-eks-node-build"
	Project = "sre-lab"
	Phase = "3"
	BuiltBy = "Packer"
  }
}

build {
  name = "sre-lab-eks-node-ami"
  
  sources = [
    "source.amazon-ebs.eks_node"
  ]
  
  provisioner "shell" {
    script = "scripts/install-node-tools.sh"
  }
}