provider "aws" {
  region  = "us-east-2"
  profile = "terraform_learn"

  default_tags {
    tags = {
      Project     = "aws-sre-reliability-lab"
      Environment = "phase2-ecs"
      Owner       = "Matthew"
      ManagedBy   = "Terraform"
    }
  }
}