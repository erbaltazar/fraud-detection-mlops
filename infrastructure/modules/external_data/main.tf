terraform {
  required_providers {
    aiven   = { source = "aiven/aiven" }
    upstash = { source = "upstash/upstash" }
    neon    = { source = "kislerdm/neon" }
  }
}

variable "aiven_project_name" {
  type        = string
  description = "Aiven project name for Kafka"
}

# 1. Event Streaming Broker (Aiven Free Apache Kafka)
resource "aiven_kafka" "fraud_stream" {
  project                 = var.aiven_project_name
  cloud_name              = "aws-ap-southeast-1" 
  plan                    = "free"
  service_name            = "mlops-fraud-kafka"
  maintenance_window_dow  = "sunday"
  maintenance_window_time = "10:00:00"
}

# 2. Feast Online Store (Upstash Serverless Redis)
resource "upstash_redis_database" "feast_online_store" {
  database_name = "mlops-feast-store"
  region        = "global" 
  tls           = true
}

# 3. Model Registry & Feast Offline Store (Neon Serverless PostgreSQL)
resource "neon_project" "mlops_backend" {
  name       = "mlops-proj"
  region_id  = "aws-ap-southeast-1" 
  pg_version = 15
}