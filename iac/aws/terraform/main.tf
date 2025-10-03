# EKS Cluster Module
module "eks" {
  source  = "./modules/eks"
  project = var.project
  tags    = local.common_tags
  subnet  = var.subnet
}
