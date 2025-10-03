locals {
  common_tags = merge(
    var.tags,
    {
      Environment = "dev"
      Project     = var.project
      ManagedBy   = "Terraform"
    }
  )

  name_prefix = "local-${var.project}"
}
