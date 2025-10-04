# Data sources
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "existing_vpc" {
  tags = {
    Name = var.vpc_name # Replace with the Name tag value
  }
}
