# Security Group for EC2 Instance (SSM Host):
resource "aws_security_group" "ec2_ssm_sg" {
  name        = "ec2-ssm-sg"
  description = "Security group for SSM Host"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH access (restrict to your IP)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]  # Use the variable!  **CHANGE THIS**
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound
  }

  tags = {
    Name = "SSM Security Group"
  }
}

# Security Group for RDS Instance:
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow connections to RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow MySQL from SSM Host"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2_ssm_sg.id] # Important: Allow from SSM Host SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS Security Group"
  }
}
