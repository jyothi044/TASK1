data "aws_vpc" "selected" {
  id = "vpc-0170241f47915e239"
}


# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.fastapi_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-north-1a" # pick any AZ

  tags = {
    Name = "fastapi-public-subnet"
  }
}

# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.fastapi_vpc.id

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

# Reference existing security group (replace with actual security group ID)
data "aws_security_group" "rds_sg" {
  id = "sg-053c9577e60545b6d" # Replace with the actual GroupId for rds-security-group-new
}

# Subnet group (RDS requires one)
resource "aws_db_subnet_group" "public_subnet_group" {
  name       = "public-subnet-group"
  subnet_ids = [aws_subnet.public_subnet.id]

  tags = {
    Name = "public-subnet-group"
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
  publicly_accessible  = true
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.public_subnet_group.name
}
