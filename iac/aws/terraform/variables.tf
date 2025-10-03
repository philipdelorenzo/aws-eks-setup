variable "project" {
  description = "Name of the project"
  type        = string
}

variable "network_id" {
  description = "The network ID of the CIDR notation"
}

variable "REGION" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
