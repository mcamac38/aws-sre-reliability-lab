output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_identity_arn" {
  value = data.aws_caller_identity.current.arn
}

output "ec2_instance_id" {
  value = module.ec2_web.instance_id
}

output "ec2_public_ip" {
  value = module.ec2_web.public_ip
}

output "ec2_public_dns" {
  value = module.ec2_web.public_dns
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