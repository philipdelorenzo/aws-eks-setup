# --- EKS Cluster Module Configuration ---
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  #version = "~> 20.0" # Use a specific version

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.32" # Specify your desired Kubernetes version

  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnets
  enable_irsa = true # Enable IAM Roles for Service Accounts (IRSA)

  # Optional: Adds the current AWS caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  # Managed Node Group Configuration
  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]              # Choose appropriate instance types
      subnet_ids     = module.vpc.private_subnets # Typically nodes run in private subnets

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
