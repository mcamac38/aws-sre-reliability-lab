data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_security_group" "web" {
  name = "${var.name_prefix}-web-sg"
  description = "Allow HTTP inbound traffic for EC2 web test"
  
  ingress {
    description = "HTTP from internet to test web server"
	from_port = 80
	to_port = 80
	protocol = "tcp"
	cidr_blocks = [var.allowed_http_cidr]
  }
  
  egress {
    description = "Allow outbout internet access"
	from_port = 0
	to_port = 0
	protocol = "-1"
	cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.name_prefix}-web-sg"
  }
 }
 
 resource "aws_instance" "web" {
   ami = data.aws_ssm_parameter.amazon_linux_2023.value
   instance_type = var.instance_type
   associate_public_ip_address = true
   vpc_security_group_ids = [aws_security_group.web.id]
   
   
   user_data = <<-EOF
				#!/bin/bash
				dnf update -y
				dnf install -y nginx
				systemctl enable nginx
				systemctl start nginx
				
				cat > /usr/share/nginx/html/index.html <<HTML
				<!DOCTYPE html>
				<html>
				  <head>
				    <title>AWS SRE Reliability Lab</title>
				  </head>
				  <body>
				    <h1>AWS SRE Reliability Lab Stuff</h1>
					<p>Phase 1 EC2 web server deployed with Terraform.</p>
					<p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
				  </body>
				</html>
				HTML
				EOF

	metadata_options {
	  http_tokens = "required"
	}
	
	tags = {
	  Name = "${var.name_prefix}-web"
	}
}
   