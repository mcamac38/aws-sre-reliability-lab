resource "aws_cloudwatch_metric_alarm" "eks_node_cpu_high" {
  alarm_name          = "${local.name_prefix}-node-cpu-high"
  alarm_description   = "Average EKS node CPU utilization is above 70%."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  metric_name         = "node_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_eks_cluster.main.name
  }

  tags = merge(local.common_tags, {
    Name      = "${local.name_prefix}-node-cpu-high"
    Component = "observability"
  })
}

resource "aws_cloudwatch_metric_alarm" "eks_node_memory_high" {
  alarm_name          = "${local.name_prefix}-node-memory-high"
  alarm_description   = "Average EKS node memory utilization is above 75%."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  metric_name         = "node_memory_utilization"
  namespace           = "ContainerInsights"
  period              = 60
  statistic           = "Average"
  threshold           = 75
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_eks_cluster.main.name
  }

  tags = merge(local.common_tags, {
    Name      = "${local.name_prefix}-node-memory-high"
    Component = "observability"
  })
}

resource "aws_cloudwatch_metric_alarm" "eks_failed_nodes" {
  alarm_name          = "${local.name_prefix}-failed-nodes"
  alarm_description   = "One or more EKS worker nodes are reporting failed conditions."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  metric_name         = "cluster_failed_node_count"
  namespace           = "ContainerInsights"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_eks_cluster.main.name
  }

  tags = merge(local.common_tags, {
    Name      = "${local.name_prefix}-failed-nodes"
    Component = "observability"
  })
}

resource "aws_cloudwatch_metric_alarm" "eks_failed_apps_pods" {
  alarm_name          = "${local.name_prefix}-failed-app-pods"
  alarm_description   = "One or more sre-lab namespace pods are in failed status."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  metric_name         = "pod_status_failed"
  namespace           = "ContainerInsights"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_eks_cluster.main.name
    Namespace   = "sre-lab"
  }

  tags = merge(local.common_tags, {
    Name      = "${local.name_prefix}-failed-app-pods"
    Component = "observability"
  })
}