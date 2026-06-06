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