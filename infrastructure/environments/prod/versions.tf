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
  }

  required_version = ">= 1.15.0"
}