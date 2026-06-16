resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${aws_eks_cluster.main.name}/cluster"
  retention_in_days = 7

  tags = merge(local.common_tags, {
    Name      = "${local.name_prefix}-eks-control-plane-logs"
    Component = "observability"
  })
}

resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "amazon-cloudwatch-observability"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(local.common_tags, {
    Name      = "${local.name_prefix}-cloudwatch-observability-addon"
    Component = "observability"
  })

  depends_on = [
    aws_eks_node_group.main,
    aws_iam_role_policy_attachment.eks_cloudwatch_agent_server_policy
  ]
}