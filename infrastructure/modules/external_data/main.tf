terraform {
  required_providers {
    upstash = { source = "upstash/upstash" }
    neon    = { source = "kislerdm/neon" }
    aiven   = { source = "aiven/aiven" }
  }
}

# 1. Feast Online Store (Upstash Serverless Redis)
resource "upstash_redis_database" "feast_online_store" {
  database_name = "mlops-feast-store"
  region        = "global"
  primary_region = "ap-northeast-1"
  tls           = true
}

# 2. Model Registry & Feast Offline Store (Neon Serverless PostgreSQL)
resource "neon_project" "mlops_backend" {
  name       = "mlops-proj"
  region_id  = "aws-ap-southeast-1" 
  pg_version = 15
  org_id     = var.neon_org_id
  history_retention_seconds = 21600
}

# 3. Kafka (Aiven Kafka)
resource "aiven_kafka" "fraud_stream" {
  project                 = var.aiven_project_name
  plan                    = "free-0"
  service_name            = "mlops-fraud-stream"
  maintenance_window_dow  = "sunday"
  maintenance_window_time = "10:00:00"
}