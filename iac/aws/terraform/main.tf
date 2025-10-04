# EKS Cluster Module
module "network" {
  source      = "./modules/network"
  vpc_name    = var.vpc_name
  subnet      = var.subnet
  environment = var.environment

  tags = var.tags
}
module "eks" {
  source      = "./modules/eks"
  vpc_id      = var.vpc_id != "" ? var.vpc_id : module.network.vpc_id
  subnet_ids  = module.network.eks_subnet_ids
  region      = var.region
  environment = var.environment
  tags        = var.tags
}
