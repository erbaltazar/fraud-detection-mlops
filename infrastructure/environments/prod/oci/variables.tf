variable "tenancy_ocid" { type = string }
variable "user_ocid" { type = string }
variable "fingerprint" { type = string }
variable "private_key" { type = string }
variable "region" { type = string }
variable "compartment_ocid" { type = string }
variable "ssh_public_key" { type = string }
variable "local_ip" { type = string }
variable "ssh_private_key" {
  description = "SSH private key for remote execution"
  type        = string
  sensitive   = true
}
variable "infisical_client_id" {
  type        = string
  description = "Infisical Universal Auth Client ID"
  sensitive   = true
}
variable "infisical_client_secret" {
  type        = string
  description = "Infisical Universal Auth Client Secret"
  sensitive   = true
}
variable "infisical_workspace_id" {
  description = "The Workspace (Project) ID from Infisical"
  type        = string
}

