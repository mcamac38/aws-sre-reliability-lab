data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
	values = [data.aws_vpc.default.id]
  }
}


data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_cloudwatch_log_group" "web" {
  name 				= "/aws/sre-lab/${var.name_prefix}/ec2-web"
  retention_in_days = var.log_retention_days
  
  tags = {
    Name = "${var.name_prefix}-ec2-web-logs"
  }
}

resource "aws_iam_role" "web" {
  name = "${var.name_prefix}-ec2-web-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
	Statement = [
	  {
	    Effect = "Allow"
		Principal = {
		  Service = "ec2.amazonaws.com"
		}
		Action = "sts:AssumeRole"
	  }
	]
  })
  
  tags = {
    Name = "${var.name_prefix}-ec2-web-role"
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role 		 = aws_iam_role.web.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role 		 = aws_iam_role.web.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "web" {
  name = "${var.name_prefix}-ec2-web-profile"
  role = aws_iam_role.web.name
}

resource "aws_security_group" "alb" {
  name = "${var.name_prefix}-alb-sg"
  description = "Allow HTTP inbound traffic to the Application Load Balancer."
  
  ingress {
    description = "HTTP from internet to ALB."
	from_port   = 80
	to_port     = 80
	protocol    = "tcp"
	cidr_blocks  = [var.allowed_http_cidr]
  }
  
  egress {
    description = "Allow outbound traffic from ALB."
	from_port   = 0
	to_port     = 0
	protocol    = "-1"
	cidr_blocks  = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.name_prefix}-alb-sg"
  }
}

resource "aws_security_group" "web" {
  name 		  = "${var.name_prefix}-web-sg"
  description = "Allow HTTP inbound traffic for EC2 web test"
  
  ingress {
    description 	= "HTTP from ALB to EC2"
	from_port   	= 80
	to_port 		= 80
	protocol 		= "tcp"
	security_groups = [aws_security_group.alb.id]
  }
  
  egress {
    description = "Allow outbound internet access"
	from_port 	= 0
	to_port 	= 0
	protocol 	= "-1"
	cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.name_prefix}-web-sg"
  }
 }
  
resource "aws_launch_template" "web" {
  name_prefix 	= "${var.name_prefix}-web-"
  image_id 	  	= data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type = var.instance_type
  
  iam_instance_profile {
    name = aws_iam_instance_profile.web.name
  }
  
  network_interfaces {
    associate_public_ip_address = true
	security_groups 			= [aws_security_group.web.id]
  }
  
  metadata_options {
    http_tokens = "required"
  }
 
   
   user_data = base64encode(<<EOF
#!/bin/bash

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
set -x

echo "Starting Phase 1D Auto Scaling user_data script"

dnf update -y
dnf install -y nginx

systemctl enable nginx
systemctl start nginx

TOKEN=$(curl -sS -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600") || true

if [ -n "$TOKEN" ]; then
  INSTANCE_ID=$(curl -sS -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id) || INSTANCE_ID="unknown"
else
  INSTANCE_ID="unknown"
fi

mkdir -p /usr/share/nginx/html

cat > /usr/share/nginx/html/index.html <<HTML
<!DOCTYPE html>
<html>
  <head>
    <title>AWS SRE Reliability Lab</title>
  </head>
  <body>
    <h1>AWS SRE Reliability Lab</h1>
    <p>Phase 1D EC2 web server launched by an Auto Scaling Group behind an Applicaton Load Balancer.</p>
    <p>Instance ID: $INSTANCE_ID</p>
  </body>
</html>
HTML

dnf install -y amazon-cloudwatch-agent || echo "CloudWatch Agent package install failed; continuing with Nginx running."

if [ -x /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl ]; then
  cat > /opt/aws/amazon-cloudwatch-agent/bin/config.json <<'CWCONFIG'
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "${aws_cloudwatch_log_group.web.name}",
            "log_stream_name": "{instance_id}/nginx/access.log"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "${aws_cloudwatch_log_group.web.name}",
            "log_stream_name": "{instance_id}/nginx/error.log"
          },
          {
            "file_path": "/var/log/user-data.log",
            "log_group_name": "${aws_cloudwatch_log_group.web.name}",
            "log_stream_name": "{instance_id}/user-data.log"
          }
        ]
      }
    }
  }
}
CWCONFIG

  /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
    -s || echo "CloudWatch Agent start failed; continuing with Nginx running."
fi

systemctl status nginx --no-pager || true
curl -I http://localhost || true

echo "Phase 1D Auto Scaling user_data script completed"
EOF
  )
		
	tags = {
	  Name = "${var.name_prefix}-web"
	}
}
   
resource "aws_lb" "web" {
  name				 = "${var.name_prefix}-web-alb"
  internal			 = false
  load_balancer_type = "application"
  security_groups	 = [aws_security_group.alb.id]
  subnets			 = data.aws_subnets.default.ids
  
  tags = {
    Name = "${var.name_prefix}-web-alb"
  }
}

resource "aws_lb_target_group" "web" {
  name		  = "${var.name_prefix}-web-tg"
  port		  = 80
  protocol	  = "HTTP"
  target_type = "instance"
  vpc_id 	  = data.aws_vpc.default.id

  health_check {
    enabled				= true
	path				= "/"
	protocol			= "HTTP"
	matcher				= "200-399"
	interval			= 30
	timeout				= 5
	healthy_threshold	= 2
	unhealthy_threshold = 2
  }
  
  tags = {
    Name = "${var.name_prefix}-web-tg"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port 				= 80
  protocol			= "HTTP"
  
  default_action {
    type = "forward"
	target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_autoscaling_group" "web" {
  name						= "${var.name_prefix}-web-asg"
  min_size					= var.asg_min_size
  max_size					= var.asg_max_size
  desired_capacity			= var.asg_desired_capacity
  vpc_zone_identifier		= data.aws_subnets.default.ids
  target_group_arns			= [aws_lb_target_group.web.arn]
  health_check_type			= "ELB"
  health_check_grace_period = var.health_check_grace_period
  
  launch_template {
    id		= aws_launch_template.web.id
	version = "$Latest"
  }
  
  tag {
    key					= "Name"
	value				= "${var.name_prefix}-web-asg-instance"
	propagate_at_launch = true
  }
  
  tag {
    key					= "Project"
	value				= "aws-sre-reliability-lab"
	propagate_at_launch = true
  }

  tag {
    key					= "Environment"
	value				= "dev"
	propagate_at_launch = true
  }

  tag {
    key					= "ManagedBy"
	value				= "Terraform"
	propagate_at_launch = true
  }
  
  depends_on = [
    aws_lb_listener.http,
	aws_iam_role_policy_attachment.cloudwatch_agent,
	aws_iam_role_policy_attachment.ssm_core
  ]
}
  
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name 		  = "${var.name_prefix}-asg-high_cpu"
  alarm_description   = "Alarm when EC2 CPU utilization is high for the SRE lab Auto Scaling Group."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name 		  = "CPUUtilization"
  namespace 		  = "AWS/EC2"
  period 			  = 300
  statistic 		  = "Average"
  threshold 		  = 70
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }
  
  tags = {
    Name = "${var.name_prefix}-asg-high-cpu"
  }
}