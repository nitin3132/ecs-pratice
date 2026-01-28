module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name    = var.name
  vpc_id  = var.vpc_id
  subnets = var.public_subnet_ids

  internal = false

  security_group_ingress_rules = {
    http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = var.my_ip_cidr
    }
  }

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      forward = { target_group_key = "app" }
    }
  }

  target_groups = {
    app = {
      target_type      = "ip"
      backend_protocol = "HTTP"
      backend_port     = var.target_port

      health_check = {
        enabled             = true
        path                = "/"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        matcher             = "200-399"
      }
    }
  }

  tags = var.tags
}

output "alb_dns_name" { value = module.alb.dns_name }
output "alb_zone_id"  { value = module.alb.zone_id }
