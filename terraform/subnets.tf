
locals {
  subnets = {
    public_1a = {
      name   = "ecommerce-public-1a"
      cidr   = "10.0.1.0/24"
      az     = "us-east-1a"
      public = true
    }

    public_1b = {
      name   = "ecommerce-public-1b"
      cidr   = "10.0.2.0/24"
      az     = "us-east-1b"
      public = true
    }

    app_1a = {
      name   = "ecommerce-app-private-1a"
      cidr   = "10.0.11.0/24"
      az     = "us-east-1a"
      public = false
    }

    app_1b = {
      name   = "ecommerce-app-private-1b"
      cidr   = "10.0.12.0/24"
      az     = "us-east-1b"
      public = false
    }

    db_1a = {
      name   = "ecommerce-db-private-1a"
      cidr   = "10.0.21.0/24"
      az     = "us-east-1a"
      public = false
    }

    db_1b = {
      name   = "ecommerce-db-private-1b"
      cidr   = "10.0.22.0/24"
      az     = "us-east-1b"
      public = false
    }
  }
}

resource "aws_subnet" "main" {
  for_each = local.subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.public

  tags = {
    Name = each.value.name
    Tier = each.value.public ? "Public" : "Private"
  }
}
