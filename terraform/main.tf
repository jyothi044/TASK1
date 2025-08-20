
# --- Use existing subnets ---
data "aws_subnet" "subnet_a" {
  id = "subnet-08e25c33826c63c6f" # fastapi-subnet-a
}

data "aws_subnet" "subnet_b" {
  id = "subnet-0e89af54f58472c0f" # fastapi-subnet-b
}

# --- Use existing Security Group ---
# Replace with the correct SG ID from your list
data "aws_security_group" "postgres_sg" {
  id = "sg-0a424524c1c3ed678"
}

# --- DB Subnet Group ---
resource "aws_db_subnet_group" "postgres_subnet_group" {
  name       = "fastapi-postgres-subnet-group"
  subnet_ids = [
    data.aws_subnet.subnet_a.id,
    data.aws_subnet.subnet_b.id
  ]

  tags = {
    Name = "fastapi-postgres-subnet-group"
  }
}

# --- RDS Instance ---
resource "aws_db_instance" "postgres" {
  identifier             = "fastapi-postgres"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = var.db_instance_class
  username               = var.db_username
  password               = var.db_password
  db_name                = var.db_name
  parameter_group_name   = "default.postgres16"
  skip_final_snapshot    = true
  publicly_accessible    = true

  vpc_security_group_ids = [data.aws_security_group.postgres_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.postgres_subnet_group.name

  tags = {
    Name = "fastapi-postgres-db"
  }
}
