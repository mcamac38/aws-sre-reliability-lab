output "instance_id" {
  description = "ID of the EC2 instance"
  value = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP address of the EC instance."
  value = aws_instance.web.public_ip
}

output "public_dns" {
  description = "Public DNS name of the EC2 instance."
  value = aws_instance.web.public_dns
}

output "website_url" {
  description = "HTTP URL for the test web server."
  value = "http://${aws_instance.web.public_dns}"
}