resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.name}"
  retention_in_days = 7
  tags              = var.tags
}

resource "aws_security_group" "service" {
  name        = "${var.name}-svc"
  description = "ECS service SG"
  vpc_id      = var.vpc_id

  # ALB will talk to this later. For now we allow VPC CIDR.
  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["10.20.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.0"

  cluster_name = "${var.name}-cluster"

  services = {
    app = {
      cpu          = 256
      memory       = 512
      desired_count = 1
      launch_type  = "FARGATE"

      subnet_ids         = var.private_subnet_ids
      security_group_ids = [aws_security_group.service.id]

      container_definitions = {
        app = {
          image     = var.container_image
          essential = true

          port_mappings = [
            { containerPort = var.container_port, protocol = "tcp" }
          ]

          log_configuration = {
            logDriver = "awslogs"
            options = {
              awslogs-group         = aws_cloudwatch_log_group.app.name
              awslogs-region        = var.aws_region
              awslogs-stream-prefix = "app"
            }
          }
        }
      }
    }
  }

  tags = var.tags
}

output "service_sg_id" {
  value = aws_security_group.service.id
}
