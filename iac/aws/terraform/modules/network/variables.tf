# variables.tf
variable "vpc_name" {
  description = "The VPC Name where the Aurora cluster will be deployed."
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}

variable "subnet" {
  description = "The subnet for the Aurora cluster."
  type        = string
}

variable "common_tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
