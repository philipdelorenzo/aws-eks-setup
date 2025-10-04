# 1. Create an AWS subnet for each CIDR and pair it with an AZ
resource "aws_subnet" "eks_subnet" {
  vpc_id     = data.aws_vpc.existing_vpc.id
  cidr_block = var.subnet

  # Cycle through the available AZs so each subnet is in a different AZ
  availability_zone = data.aws_availability_zones.available.names[var.subnet]
}
