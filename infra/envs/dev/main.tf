########################################
# STEP 1: VPC (Enable first)
########################################
module "vpc" {
  source = "../../modules/vpc"

  name       = local.name
  cidr_block = "10.20.0.0/16"

  azs = ["ca-central-1a", "ca-central-1b"]

  public_subnets  = ["10.20.1.0/24", "10.20.2.0/24"]
  private_subnets = ["10.20.11.0/24", "10.20.12.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = local.tags
}

########################################
# STEP 2: VPC Endpoints (uncomment later)
########################################
# module "vpc_endpoints" {
#   source = "../../modules/vpc_endpoints"
#   vpc_id             = module.vpc.vpc_id
#   private_subnet_ids = module.vpc.private_subnet_ids
#   tags               = local.tags
# }

########################################
# STEP 3: ECR (uncomment later)
########################################
# module "ecr" {
#   source    = "../../modules/ecr"
#   repo_name = "${local.name}-app"
#   tags      = local.tags
# }

########################################
# STEP 4: ECS (uncomment later)
########################################
# module "ecs" {
#   source             = "../../modules/ecs"
#   name               = local.name
#   aws_region         = var.aws_region
#   vpc_id             = module.vpc.vpc_id
#   private_subnet_ids = module.vpc.private_subnet_ids
#   container_image    = "${module.ecr.repository_url}:latest"
#   container_port     = 8080
#   tags               = local.tags
# }

########################################
# STEP 5: ALB Public (uncomment later)
########################################
# module "alb" {
#   source            = "../../modules/alb"
#   name              = local.name
#   vpc_id            = module.vpc.vpc_id
#   public_subnet_ids = module.vpc.public_subnet_ids
#   my_ip_cidr        = var.my_ip_cidr
#   target_port       = 8080
#   tags              = local.tags
# }

########################################
# STEP 6: Route53 (uncomment later)
########################################
# module "route53" {
#   source      = "../../modules/route53"
#   zone_name   = var.zone_name
#   record_name = var.record_name
#   alb_dns_name = module.alb.alb_dns_name
#   alb_zone_id  = module.alb.alb_zone_id
#   tags         = local.tags
# }
