output "launch_template_id" {
  description = "ID of the EC2 launch template."
  value       = aws_launch_template.web.id
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group."
  value       = aws_autoscaling_group.web.name
}

output "website_url" {
  description = "HTTP URL for the Application Load Balancer."
  value 	  = "http://${aws_lb.web.dns_name}"
}

output "load_balancer_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value 	  = aws_lb.web.dns_name
}

output "load_balancer_url" {
  description = "HTTP URL for the Application Load Balancer."
  value		  = "http://${aws_lb.web.dns_name}"
}

output "target_group_arn" {
  description = "ARN of the ALB target group"
  value		  = aws_lb_target_group.web.arn
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for the EC2 web server."
  value		  = aws_cloudwatch_log_group.web.name
}

output "high_cpu_alarm_name" {
  description = "Name of the CloudWatch alarm for high ASG CPU utilization."
  value		  = aws_cloudwatch_metric_alarm.high_cpu.alarm_name
}