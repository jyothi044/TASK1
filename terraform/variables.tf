variable "db_username" {
  description = "Postgres username"
  type        = string
  default     = "api_user"
}

variable "db_password" {
  description = "Postgres password"
  type        = string
  default     = "root"
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "fastapi_db"
}

variable "db_instance_class" {
  description = "RDS instance type (free tier eligible)"
  type        = string
  default     = "db.t3.micro"
}
