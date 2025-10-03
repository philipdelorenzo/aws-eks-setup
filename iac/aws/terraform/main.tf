# VPC
module "vpc" {
  source     = "./modules/vpc"
  project    = var.project
  tags       = local.common_tags
  vpc_cidr   = var.vpc_cidr
  network_id = var.network_id
}

# Security Group Module
module "security-groups" {
  source         = "./modules/security-groups"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  tags           = local.common_tags
}
