output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "kubeconfig" {
  description = "The kubeconfig file generated for the cluster"
  value       = module.eks.kubeconfig
}

output "region" {
  description = "AWS region"
  value       = module.eks.region
}
