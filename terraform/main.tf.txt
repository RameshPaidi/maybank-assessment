# Create VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "main-vpc"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

# Create Public Subnets
resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true # Important for SSM
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

# Create Private Subnets
resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

# Create public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate public route table with public subnets
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(aws_subnet.public_subnets[*].id)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Create NAT Gateway (in a public subnet) - one per AZ for HA
resource "aws_nat_gateway" "nat_gateways" {
  count         = length(var.public_subnet_cidr)
  allocation_id = aws_eip.nat_ips[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id

  tags = {
    Name = "nat-gateway-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.gw] # Ensure IGW is created first
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat_ips" {
  count = length(var.public_subnet_cidr)
  domain = "vpc"

  tags = {
    Name = "nat-eip-${count.index + 1}"
  }
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateways[0].id # Route all traffic through the NAT Gateway
  }

  tags = {
    Name = "private-route-table"
  }
}

# Associate private route table with private subnets
resource "aws_route_table_association" "private_subnet_association" {
  count = length(aws_subnet.private_subnets[*].id)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

# Create DB Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = aws_subnet.private_subnets[*].id

  tags = {
    Name = "RDS Subnet Group"
  }
}

# Create RDS MariaDB Instance
resource "aws_db_instance" "rds_mariadb" {
  allocated_storage    = 20
  engine               = "mariadb"
  engine_version       = "10.6" # Choose a supported version
  instance_class       = "db.t3.micro" # Choose an appropriate instance type
  name                 = "mydb"
  username             = "admin"
  password             = var.db_password  # Use the variable!
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot = true
  publicly_accessible = false # VERY IMPORTANT
  #  Monitoring role if you create it
  #  monitoring_role_arn = aws_iam_role.rds_monitoring_role.arn
}

# EC2 Instance (SSM Host) Definition:
resource "aws_instance" "ec2_ssm_host" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type # Use variable
  subnet_id              = aws_subnet.public_subnets[0].id # Place in a public subnet
  vpc_security_group_ids = [aws_security_group.ec2_ssm_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_instance_profile.name

  tags = {
    Name = "SSM Host"
  }
}
