
# 1. Frontend EC2 Security Group
resource "aws_security_group" "frontend_sg" {
  name        = "ecommerce-frontend-sg"
  description = "Allow HTTP traffic from frontend ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from frontend ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecommerce-frontend-sg"
  }
}

# 2. Frontend Application Load Balancer Security Group
resource "aws_security_group" "alb_sg" {
  name        = "ecommerce-alb-sg"
  description = "Allow public HTTP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Public HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecommerce-alb-sg"
  }
}

# 3. Backend Application Load Balancer Security Group
resource "aws_security_group" "backend_alb_sg" {
  name        = "ecommerce-backend-alb-sg"
  description = "Allow API traffic from frontend instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "API traffic from frontend instances"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecommerce-backend-alb-sg"
  }
}

# 4. Backend EC2 Security Group
resource "aws_security_group" "backend_sg" {
  name        = "ecommerce-backend-sg"
  description = "Allow API traffic from backend ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Backend API from backend ALB"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecommerce-backend-sg"
  }
}

# 5. Database Security Group
resource "aws_security_group" "database_sg" {
  name        = "ecommerce-database-sg"
  description = "Allow MySQL traffic from backend instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from backend EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecommerce-database-sg"
  }
}
