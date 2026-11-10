terraform {
  backend "s3" {
    bucket       = "ecommerce-terraform-state-venky-2026"
    key          = "ecommerce/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}