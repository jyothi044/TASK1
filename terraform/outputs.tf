output "project_id" {
  value = data.neon_project.existing_project.id
}

output "connection_uri" {
  description = "PostgreSQL connection URI (includes credentials)"
  value       = "postgresql://${var.db_username}:${var.db_password}@ep-green-water-ae7xgc68-pooler.c-2.us-east-2.aws.neon.tech/${var.database_name}?sslmode=require"
  sensitive   = true
}


output "database_name" {
  value = var.database_name
}