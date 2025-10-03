variable "vpc_name" {
  description = "Name of the existing VPC to use (this will query by the Name tag to find the VPC ID)"
  type        = string
}

variable "vpc_id" {
  description = "Optional: the VPC ID to use directly. If provided, this will be passed to the aurora module. If empty, the network module will be used to discover/create the VPC by name."
  type        = string
  default     = ""
}

variable "project" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "subnet" {
  description = "CIDR block for the subnet"
  type        = string
}

variable "REGION" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
