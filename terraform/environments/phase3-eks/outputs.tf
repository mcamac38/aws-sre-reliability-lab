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