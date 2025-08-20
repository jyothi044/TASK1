# Use existing VPC
data "aws_vpc" "selected" {
  id = "vpc-0170241f47915e239"
}

# Use existing Security Group
data "aws_security_group" "rds_sg" {
  id = "sg-053c9577e60545b6d"
}

# Use existing Internet Gateway (specific ID from screenshot)
data "aws_internet_gateway" "existing_igw" {
  id = "igw-08d5673bd0ea8f64"
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

# Route Table (using existing Internet Gateway)
resource "aws_route_table" "public_rt" {
  vpc_id = data.aws_vpc.selected.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.existing_igw.id
  }

  tags = {
    Name = "fastapi-public-rt"
  }
}

# Route Table Association for Subnet 1
resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

# Route Table Association for Subnet 2
resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
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