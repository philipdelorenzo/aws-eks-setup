output "eks_subnet_ids" {
  description = "The IDs of the subnets designated for the EKS cluster."
  value       = [aws_subnet.eks_subnet.id]
}

output "vpc_id" {
  description = "The ID of the VPC where the EKS cluster is deployed."
  value       = data.aws_vpc.existing_vpc.id
}
