data "aws_caller_identity" "current" {}

module "ec2_web" {
  source = "../../modules/ec2_web"

  name_prefix   = "sre-lab-dev"
  instance_type = "t2.micro"
}

module "ecr" {
  source          = "../../modules/ecr"
  repository_name = "sre-ecs-web"
}