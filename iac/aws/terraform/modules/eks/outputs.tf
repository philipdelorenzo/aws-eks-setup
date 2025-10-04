output "cluster_id" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "kubeconfig_connect_command" {
  description = "The AWS CLI command to update your local kubeconfig file."
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_id}"
}

output "cluster_security_group_id" {
  description = "Security group ID for the EKS cluster"
  value       = module.eks.cluster_security_group_id
}
