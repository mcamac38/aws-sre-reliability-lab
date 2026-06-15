output "name_prefix" {
  description = "Name prefix used for Phase 3 resources."
  value       = local.name_prefix
}

output "aws_region" {
  description = "AWS region used for Phase 3"
  value       = var.aws_region
}

output "vpc_id" {
  description = "ID of the Phase 3 EKS VPC."
  value       = aws_vpc.eks.id
}

output "public_subnets_ids" {
  description = "Public subnet IDs for EKS load balancers and NAT."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnets IDs for EKS worker nodes."
  value       = aws_subnet.private[*].id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID used by private EKS subnets."
  value       = aws_nat_gateway.eks.id
}

output "cluster_name" {
  description = "Planned EKS cluster name."
  value       = local.cluster_name
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster."
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for the EKS Kubernetes API server."
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_arn" {
  description = "ARN of the EKS cluster."
  value       = aws_eks_cluster.main.arn
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required for Kubernetes clients."
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "packer_eks_node_ami_id" {
  description = "Latest Packer-built EKS node AMI ID."
  value       = data.aws_ami.packer_eks_node.id
}

output "eks_node_group_name" {
  description = "Name of the EKS managed node group."
  value       = aws_eks_node_group.main.node_group_name
}

output "eks_node_group_status" {
  description = "Status of the EKS managed node group."
  value       = aws_eks_node_group.main.status
}