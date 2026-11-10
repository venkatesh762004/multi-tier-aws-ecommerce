
# Public Route Table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Public Subnet Associations

resource "aws_route_table_association" "public" {
  for_each = {
    public_1a = aws_subnet.main["public_1a"].id
    public_1b = aws_subnet.main["public_1b"].id
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

# Private Application Route Table

resource "aws_route_table" "app_private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-app-private-rt"
  }
}

resource "aws_route" "app_nat" {
  route_table_id         = aws_route_table.app_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Application Subnet Associations

resource "aws_route_table_association" "app_private" {
  for_each = {
    app_1a = aws_subnet.main["app_1a"].id
    app_1b = aws_subnet.main["app_1b"].id
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.app_private.id
}

# Private Database Route Table

resource "aws_route_table" "db_private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-db-private-rt"
  }
}

# Database Subnet Associations

resource "aws_route_table_association" "db_private" {
  for_each = {
    db_1a = aws_subnet.main["db_1a"].id
    db_1b = aws_subnet.main["db_1b"].id
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.db_private.id
}
