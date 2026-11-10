resource "aws_db_subnet_group" "ecommerce_db_subnet" {
  name = "ecommerce-db-subnet-group"

  subnet_ids = [
    aws_subnet.main["db_1a"].id,
    aws_subnet.main["db_1b"].id
  ]

  tags = {
    Name = "ecommerce-db-subnet-group"
  }
}

resource "aws_db_instance" "ecommerce" {
  identifier = "ecommerce-mysql-db"

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name                     = var.db_name
  username                    = var.db_username
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.ecommerce_db_subnet.name
  vpc_security_group_ids = [aws_security_group.database_sg.id]

  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = {
    Name = "ecommerce-mysql-db"
    Tier = "Database"
  }
}