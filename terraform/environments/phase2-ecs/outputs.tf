output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_task_definition_arn" {
  value = aws_ecs_task_definition.app.arn
}

output "ecs_log_group_name" {
  value = aws_cloudwatch_log_group.ecs_app.name
}

output "ecr_repository_url" {
  value = data.aws_ecr_repository.app.repository_url
}

output "container_image" {
  value = "${data.aws_ecr_repository.app.repository_url}:v1"
}

output "ecs_servic_name" {
  value = aws_ecs_service.app.name
}

output "alb_dns_name" {
  value = aws_lb.ecs.dns_name
}

output "alb_url" {
  value = "http://${aws_lb.ecs.dns_name}"
}

output "ecs_target_group_arn" {
  value = aws_lb_target_group.ecs.arn
}