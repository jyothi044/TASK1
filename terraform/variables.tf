variable "db_username" {
  description = "Database role username"
  type        = string
  default     = "neondb_owner"
}

variable "db_password" {
  description = "Database role password"
  type        = string
  default     = "npg_pBe6mrRVuYK0"
  sensitive   = true
}

variable "database_name" {
  description = "Database name"
  type        = string
  default     = "neondb"
}