variable "region" {
  description = "The AWS region to deploy the EKS cluster in."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the EKS cluster will be deployed."
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "subnet_ids" {
  description = "The subnet IDs for the EKS cluster."
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
