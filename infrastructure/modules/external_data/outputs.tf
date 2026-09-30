output "redis_endpoint" {
  value       = upstash_redis_database.feast_online_store.endpoint
  description = "Upstash Redis URL"
}

output "redis_password" {
  value       = upstash_redis_database.feast_online_store.password
  description = "Upstash Redis Password"
  sensitive   = true
}

output "neon_project_id" {
  value       = neon_project.mlops_backend.id
  description = "Neon PostgreSQL Project ID"
}