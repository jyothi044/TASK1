# Use the existing VPC
data "aws_vpc" "selected" {
  id = "vpc-0170241f47915e239"
}

# Reference existing subnets (replace with actual subnet IDs)
data "aws_subnet" " fastapi-subnet-a" {
  id = "subnet-0cd446cde3db3966b"
}

data "aws_subnet" "fastapi-subne-b" {
  id = "subnet-00f4aac34f5638e38" 
}

# Reference existing security group (replace with actual security group ID)
data "aws_security_group" "rds_sg" {
  id = "sg-053c9577e60545b6d" # Replace with the actual GroupId for rds-security-group-new
}

# Subnet group for RDS (using existing subnets)
resource "aws_db_subnet_group" "default" {
  name       = "default-subnet-group"
  subnet_ids = [data.aws_subnet.subnet_a.id, data.aws_subnet.subnet_b.id]
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
  vpc_security_group_ids = [data.aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
}