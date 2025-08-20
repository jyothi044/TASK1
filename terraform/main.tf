# --- Get Default VPC ---
data "aws_vpc" "default" {
  default = true
}

# --- Get Default Subnets ---
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# --- Security Group ---
resource "aws_security_group" "postgres_sg" {
  name        = "postgres-sg"
  description = "Allow Postgres inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: open to all, for demo only
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- DB Subnet Group ---
resource "aws_db_subnet_group" "default" {
  name       = "postgres-subnet-group"
  subnet_ids = data.aws_subnets.default.ids
  tags = {
    Name = "postgres-subnet-group"
  }
}

# --- RDS Instance ---
resource "aws_db_instance" "postgres" {
  identifier             = "fastapi-postgres"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = "db.t3.micro"
  username               = "postgres"
  password               = "password123"
  parameter_group_name   = "default.postgres16"
  skip_final_snapshot    = true
  publicly_accessible    = true

  vpc_security_group_ids = [aws_security_group.postgres_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
}
