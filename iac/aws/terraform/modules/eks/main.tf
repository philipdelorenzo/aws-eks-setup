# --- EKS Cluster Module Configuration ---
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0" # Use a specific version

  name               = "${var.environment}-eks-cluster"
  kubernetes_version = "1.32" # Specify your desired Kubernetes version

  vpc_id      = var.vpc_id
  subnet_ids  = var.subnet_ids
  enable_irsa = true # Enable IAM Roles for Service Accounts (IRSA)

  # Optional: Adds the current AWS caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  # Managed Node Group Configuration
  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]  # Choose appropriate instance types
      subnet_ids     = var.subnet_ids # Typically nodes run in private subnets

      # Labels to add to nodes (optional)
      labels = {
        env = "dev"
      }
    }
  }

  tags = {
    Environment = "Dev"
    Project     = "EKS-Test"
  }
}
