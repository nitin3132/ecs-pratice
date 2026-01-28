module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 2.0"

  repository_name        = var.repo_name
  repository_force_delete = true

  tags = var.tags
}

output "repository_url" {
  value = module.ecr.repository_url
}
