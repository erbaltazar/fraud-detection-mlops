# infrastructure/environments/prod/versions.tf

terraform {
  # HCP Terraform Remote Backend Configuration
  cloud {
    organization = "erbaltazar-terraform-org"
    workspaces {
      name = "fraud-detection-mlops-prod"
    }
  }

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0" 
    }
    upstash = {
      source  = "upstash/upstash"
      version = "~> 1.5"
    }
    neon = {
      source  = "kislerdm/neon"
      version = "~> 0.2"
    }
    infisical = { 
      source  = "infisical/infisical"
      version = "~> 0.19"
    }
  }

  required_version = ">= 1.15.0"
}