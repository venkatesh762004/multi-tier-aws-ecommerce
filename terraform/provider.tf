provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Multi-Tier-Ecommerce"
      Environment = "Dev"
      ManagedBy   = "Terraform"
    }
  }
}