terraform {
  required_providers {
    upstash = { source = "upstash/upstash" }
    neon    = { source = "kislerdm/neon" }
  }
}

# 1. Feast Online Store (Upstash Serverless Redis)
resource "upstash_redis_database" "feast_online_store" {
  database_name = "mlops-feast-store"
  region        = "global" 
  tls           = true
}

# 2. Model Registry & Feast Offline Store (Neon Serverless PostgreSQL)
resource "neon_project" "mlops_backend" {
  name       = "mlops-proj"
  region_id  = "aws-ap-southeast-1" 
  pg_version = 15
  org_id     = var.neon_org_id
}