# Create Security Group
resource "aws_security_group" "postgres_sg" {
  name        = "postgres-sg"
  description = "Allow Postgres access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Postgres port"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # for testing only, restrict in prod
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Data source for default VPC
data "aws_vpc" "default" {
  default = true
}

# Create Subnet group
resource "aws_db_subnet_group" "default" {
  name       = "postgres-subnet-group"
  subnet_ids = data.aws_subnets.default.ids
}

# Data source for default subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_db_instance" "postgres" {
  identifier              = "fastapi-postgres"
  engine                  = "postgres"
  engine_version          = "16.3"   # ✅ Supported in AWS
  instance_class          = var.db_instance_class
  allocated_storage       = 20
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  publicly_accessible     = true
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.postgres_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.default.name
  backup_retention_period = 7
}


