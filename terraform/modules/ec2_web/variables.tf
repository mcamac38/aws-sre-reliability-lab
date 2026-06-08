variable "name_prefix" {
  description = "Prefix used for resource names."
  type 		  = string
}

variable "instance_type" {
  description = "EC2 instance type for the web server."
  type 		  = string
  default 	  = "t2.micro"
}

variable "allowed_http_cidr" {
  description = "CIDR block allowed to access HTTP port 80."
  type 		  = string
  default 	  = "0.0.0.0/0"
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs."
  type 		  = number
  default 	  = 7
}

variable "asg_min_size" {
  description = "Minimum number of EC2 instances in the Auto Scaling Group."
  type 		  = number
  default 	  = 2
}

variable "asg_max_size" {
  description = "Maximum number of EC2 instances in the Auto Scaling Group."
  type 		  = number
  default 	  = 4
}

variable "asg_desired_capacity" {
  description = "Desired number of EC2 instances in the Auto Scaling Group." 
  type 		  = number
  default 	  = 2
}

variable "health_check_grace_period" {
  description = "Time in seconds before Auto Scaling starts checking instance health."
  type 		  = number
  default 	  = 300
}