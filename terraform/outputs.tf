output "vpc_id" {
  value = aws_vpc.main.id
  description = "The ID of the VPC"
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
  description = "List of public subnet IDs"
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
  description = "List of private subnet IDs"
}

output "ec2_instance_id" {
  value = aws_instance.ec2_ssm_host.id
  description = "The ID of the EC2 instance (SSM Host)"
}

output "rds_endpoint" {
  value = aws_db_instance.rds_mariadb.endpoint
  description = "The endpoint of the RDS MariaDB instance"
}

output "rds_port" {
  value = aws_db_instance.rds_mariadb.port
  description = "The port of the RDS MariaDB instance"
}
