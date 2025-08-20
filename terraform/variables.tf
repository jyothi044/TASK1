variable "db_username" {
  description = "Postgres username"
  type        = string
  default     = "todofast"
}

variable "db_password" {
  description = "Postgres password"
  type        = string
  default     = "Todoapi65736"
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "Todobasicdb"
}

variable "db_instance_class" {
  description = "RDS instance type (free tier eligible)"
  type        = string
  default     = "db.t3.micro"
}
