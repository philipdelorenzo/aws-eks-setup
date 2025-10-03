# EKS Cluster Module
module "network" {
  source      = "./modules/network"
  vpc_name    = var.vpc_name
  subnet      = var.subnet
  environment = var.environment

  common_tags = var.common_tags
}
module "eks" {
  source  = "./modules/eks"
  project = var.project
  tags    = local.common_tags
  subnet  = var.subnet
}
