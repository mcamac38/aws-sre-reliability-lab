output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_identity_arn" {
  value = data.aws_caller_identity.current.arn
}

output "launch_template_id" {
  value = module.ec2_web.launch_template_id
}

output "autoscaling_group_name" {
  value = module.ec2_web.autoscaling_group_name
}

output "website_url" {
  value = module.ec2_web.website_url
}

output "load_balancer_dns_name" {
  value = module.ec2_web.load_balancer_dns_name
}

output "load_balancer_url" {
  value = module.ec2_web.load_balancer_url
}

output "target_group_arn" {
  value = module.ec2_web.target_group_arn
}

output "cloudwatch_log_group_name" {
  value = module.ec2_web.cloudwatch_log_group_name
}

output "high_cpu_alarm_name" {
  value = module.ec2_web.high_cpu_alarm_name
}