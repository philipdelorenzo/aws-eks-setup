provider "aws" {
  region  = var.REGION
  profile = var.profile
}

terraform {
  backend "s3" {
    bucket  = var.bucket
    key     = "${var.project}/dev/terraform.tfstate"
    profile = var.profile
    region  = var.REGION
  }
}

module "eks_stack" {
  source  = "../../"
  project = var.project
  subnet  = var.subnet
}
