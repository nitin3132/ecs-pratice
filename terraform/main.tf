terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "ecs-pratice-terraform-state"
    key            = "ecs-pratice/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = "ecs-pratice"
    }
  }
}

module "vpc" {
  source = "./modules/vpc"

  environment           = var.environment
  vpc_cidr              = var.vpc_cidr
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
}

module "iam" {
  source = "./modules/iam"

  environment = var.environment
}

module "alb" {
  source = "./modules/alb"

  environment             = var.environment
  vpc_id                  = module.vpc.vpc_id
  alb_security_group_id   = module.vpc.alb_security_group_id
  public_subnets          = module.vpc.public_subnets
  container_port          = var.container_port
  health_check_path       = var.health_check_path
}

module "ecs" {
  source = "./modules/ecs"

  environment                    = var.environment
  aws_region                     = var.aws_region
  container_name                 = var.container_name
  container_image                = var.container_image
  container_port                 = var.container_port
  container_cpu                  = var.container_cpu
  container_memory               = var.container_memory
  container_environment_variables = var.container_environment_variables
  desired_count                  = var.desired_count
  max_capacity                   = var.max_capacity
  log_retention_days             = var.log_retention_days
  private_subnets                = module.vpc.private_subnets
  ecs_tasks_security_group_id    = module.vpc.ecs_tasks_security_group_id
  target_group_arn               = module.alb.target_group_arn
  alb_listener_arn               = module.alb.alb_dns_name
  ecs_task_execution_role_arn    = module.iam.ecs_task_execution_role_arn
  ecs_task_role_arn              = module.iam.ecs_task_role_arn
}
