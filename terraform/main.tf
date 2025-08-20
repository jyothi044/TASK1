# Use existing VPC
data "aws_vpc" "selected" {
  id = "vpc-0170241f47915e239"
}

# Use existing Security Group
data "aws_security_group" "rds_sg" {
  id = "sg-0a5e5063632dd3715"
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = data.aws_vpc.selected.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-north-1a"

  tags = {
    Name = "fastapi-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = data.aws_vpc.selected.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-north-1c"

  tags = {
    Name = "fastapi-public-subnet-2"
  }
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "subnet"
  subnet_ids = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name = "subnet"
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
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name
}