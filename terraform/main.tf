# Use existing VPC
data "aws_vpc" "selected" {
  id = "vpc-0170241f47915e239"
}

# Use existing Security Group
data "aws_security_group" "rds_sg" {
  id = "sg-053c9577e60545b6d"
}

# Public Subnet 1 (in eu-north-1b)
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = data.aws_vpc.selected.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-north-1b"

  tags = {
    Name = "fastapi-public-subnet-1"
  }
}

# Public Subnet 2 (in eu-north-1a for AZ coverage)
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = data.aws_vpc.selected.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-north-1c"

  tags = {
    Name = "fastapi-public-subnet-2"
  }
}

# Subnet group for RDS (include both subnets for AZ coverage)
resource "aws_db_subnet_group" "public_subnet_group" {
  name       = "public-subnet-group"
  subnet_ids = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name = "public-subnet-group"
  }
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "postgres" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = var.db_instance_class
  username               = var.db_username
  password               = var.db_password
  db_name                = var.db_name
  publicly_accessible    = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [data.aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.public_subnet_group.name
}