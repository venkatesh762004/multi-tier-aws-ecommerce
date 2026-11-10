
output "vpc_id" {
  description = "E-Commerce VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value = [
    aws_subnet.main["public_1a"].id,
    aws_subnet.main["public_1b"].id
  ]
}

output "app_private_subnet_ids" {
  description = "Application private subnet IDs"
  value = [
    aws_subnet.main["app_1a"].id,
    aws_subnet.main["app_1b"].id
  ]
}


output "database_endpoint" {
  description = "RDS MySQL endpoint"
  value       = aws_db_instance.ecommerce.endpoint
}

output "database_name" {
  description = "Database name"
  value       = aws_db_instance.ecommerce.db_name
}
