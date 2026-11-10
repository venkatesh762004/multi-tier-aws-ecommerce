
# Elastic IP for NAT Gateway

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

# NAT Gateway

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.main["public_1a"].id

  tags = {
    Name = "${var.project_name}-nat-gateway"
  }

  depends_on = [
    aws_internet_gateway.igw
  ]
}
