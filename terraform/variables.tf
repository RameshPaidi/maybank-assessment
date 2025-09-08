variable "region" {
  type    = string
  default = "us-east-1"  # Change to your desired region
  description = "AWS region"
}

variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/16"
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr" {
  type    = list(string)
  default = ["192.168.1.0/24", "192.168.2.0/24"]
  description = "CIDR blocks for the public subnets"
}

variable "private_subnet_cidr" {
  type    = list(string)
  default = ["192.168.3.0/24", "192.168.4.0/24"]
  description = "CIDR blocks for the private subnets"
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"] 
  description = "List of availability zones"
}

variable "db_password" {
  type    = string
  sensitive = true 
  description = "Password for the MariaDB database"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
  description = "EC2 instance type"
}

variable "allowed_ssh_cidr" {
  type    = string
  default = "0.0.0.0/0"
  description = "CIDR block allowed to SSH to the SSM Host"
}
