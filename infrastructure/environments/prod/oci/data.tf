ephemeral "infisical_secret" "upstash_email" {
  name         = "UPSTASH_EMAIL"
  env_slug     = "prod"
  workspace_id = var.infisical_workspace_id
  folder_path  = "/"
}

ephemeral "infisical_secret" "upstash_key" {
  name         = "UPSTASH_API_KEY"
  env_slug     = "prod"
  workspace_id = var.infisical_workspace_id
  folder_path  = "/"
}

ephemeral "infisical_secret" "neon_key" {
  name         = "NEON_API_KEY"
  env_slug     = "prod"
  workspace_id = var.infisical_workspace_id
  folder_path  = "/"
}

ephemeral "infisical_secret" "aiven_token" {
  name         = "AIVEN_API_TOKEN"
  env_slug     = "prod"
  workspace_id = var.infisical_workspace_id
  folder_path  = "/"
}