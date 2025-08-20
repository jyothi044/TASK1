
# Use existing VPC
data "aws_vpc" "selected" {
  id = "vpc-0170241f47915e239"
}

# Use existing Security Group (replace ID with yours)
data "aws_security_group" "rds_sg" {
  id = "sg-053c9577e60545b6d"
}

# Public Subnet (new)
resource "aws_subnet" "public_subnet" {
  vpc_id                  = data.aws_vpc.selected.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-north-2a"

  tags = {
    Name = "fastapi-public-subnet"
  }
}

# Internet Gateway (new, since you need public access)
resource "aws_internet_gateway" "igw" {
  vpc_id = data.aws_vpc.selected.id

  tags = {
    Name = "fastapi-igw"
  }
}

# Route Table (new)
resource "aws_route_table" "public_rt" {
  vpc_id = data.aws_vpc.selected.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "fastapi-public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Subnet group for RDS
resource "aws_db_subnet_group" "public_subnet_group" {
  name       = "public-subnet-group"
  subnet_ids = [aws_subnet.public_subnet.id]

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
