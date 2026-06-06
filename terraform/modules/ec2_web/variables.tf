variable "name_prefix" {
  description = "Prefix used for resource names."
  type = string
}

variable "instance_type" {
  description = "EC2 instance type for the web server."
  type = string
  default = "t2.micro"
}

variable "allowed_http_cidr" {
  description = "CIDR block allowed to access HTTP port 80."
  type = string
  default = "0.0.0.0/0"
}