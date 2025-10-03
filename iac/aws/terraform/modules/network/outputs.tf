output "aurora_subnet_ids" {
  description = "The IDs of the subnets designated for the Aurora DB."
  value       = [aws_subnet.aurora_db.id]
}

output "vpc_id" {
  description = "The ID of the VPC where the Aurora cluster is deployed."
  value       = data.aws_vpc.existing_vpc.id
}
