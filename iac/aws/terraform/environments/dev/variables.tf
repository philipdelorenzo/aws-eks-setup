variable "project" {
  description = "Name of the project"
  type        = string
}

variable "vpc_name" {
  description = "Name of the existing VPC to use (this will query by the Name tag to find the VPC ID)"
  type        = string
}

variable "bucket" {
  description = "S3 bucket for storing Terraform state"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "default"
}

variable "subnet" {
  description = "CIDR/Network ID block for EKS Cluster"
  type        = string
}
