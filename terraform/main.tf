

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get default subnets of default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Default security group of default VPC
data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name   = "group-name"
    values = ["default"]
  }
}

# Subnet group for RDS
resource "aws_db_subnet_group" "default" {
  name       = "default-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

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
  db_username             = var.db_username
  db_password             = var.db_password
  db_name              = var.db_name
  parameter_group_name = "default.postgres15"
  publicly_accessible  = true
  skip_final_snapshot  = true

  vpc_security_group_ids = [data.aws_security_group.default.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
}
