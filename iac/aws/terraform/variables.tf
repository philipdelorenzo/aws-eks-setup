variable "project" {
  description = "Name of the project"
  type        = string
}

variable "vpc_name" {
  description = "The VPC Name where the Aurora cluster will be deployed."
  type        = string
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
