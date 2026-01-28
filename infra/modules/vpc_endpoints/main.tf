module "endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.0"

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  endpoints = {
    s3 = {
      service      = "s3"
      service_type = "Gateway"
      tags         = var.tags
    }

    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      tags                = var.tags
    }

    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      tags                = var.tags
    }

    logs = {
      service             = "logs"
      private_dns_enabled = true
      tags                = var.tags
    }

    sts = {
      service             = "sts"
      private_dns_enabled = true
      tags                = var.tags
    }
  }

  tags = var.tags
}
