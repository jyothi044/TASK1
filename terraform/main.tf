# Use the existing VPC
data "aws_vpc" "selected" {
  id = "vpc-0170241f47915e239"
}

# Create subnets for RDS with unique CIDR blocks
resource "aws_subnet" "subnet_a" {
  vpc_id            = data.aws_vpc.selected.id
  cidr_block        = "10.0.3.0/24" # Unique CIDR
  availability_zone = "eu-north-1a"
  tags = {
    Name = "fastapi-subnet-a"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = data.aws_vpc.selected.id
  cidr_block        = "10.0.4.0/24" # Unique CIDR
  availability_zone = "eu-north-1b"
  tags = {
    Name = "fastapi-subnet-b"
  }
}

# Get the default security group of the selected VPC
data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.selected.id
  filter {
    name   = "group-name"
    values = ["default"]
  }
}

# Subnet group for RDS
resource "aws_db_subnet_group" "default" {
  name       = "default-subnet-group"
  subnet_ids = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
  tags = {
    Name = "default-subnet-group"
  }
}

# RDS Postgres instance
resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "16.3"
  instance_class       = var.db_instance_class
  username             = var.db_username
  password             = var.db_password
  db_name              = var.db_name
  parameter_group_name = "default.postgres15"
  publicly_accessible  = true
  skip_final_snapshot  = true
  vpc_security_group_ids = [data.aws_security_group.default.id] # Or use [aws_security_group.rds_sg.id] if created
  db_subnet_group_name   = aws_db_subnet_group.default.name
}

# Optional: Create a new security group with a unique name
resource "aws_security_group" "rds_sg" {
  vpc_id = data.aws_vpc.selected.id
  name   = "rds-security-group-new"
  description = "Security group for RDS"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this for production
  }
  tags = {
    Name = "rds-security-group-new"
  }
}