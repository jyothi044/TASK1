# Outputs
output "project_id" {
  value = data.neon_project.existing_project.id
}

output "connection_uri" {
  description = "PostgreSQL connection URI (includes credentials)"
  value       = "postgresql://${var.db_username}:${var.db_password}@${neon_endpoint.branch_endpoint.host}/${var.database_name}?sslmode=require&channel_binding=require"
  sensitive   = true
}

output "database_name" {
  value = var.database_name
}