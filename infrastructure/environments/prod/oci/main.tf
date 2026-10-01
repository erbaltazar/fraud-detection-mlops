provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid    = var.user_ocid
  fingerprint  = var.fingerprint
  private_key  = var.private_key
  region       = var.region
}

# Authenticate Terraform to your Vault
provider "infisical" {
  client_id     = var.infisical_client_id
  client_secret = var.infisical_client_secret
}

# Authorize the external providers dynamically
provider "upstash" {
  email   = ephemeral.infisical_secret.upstash_email.value
  api_key = ephemeral.infisical_secret.upstash_key.value
}

provider "neon" {
  api_key = ephemeral.infisical_secret.neon_key.value
}

provider "aiven" {
  api_token = ephemeral.infisical_secret.aiven_token.value
}

module "oci_infrastructure" {
  source           = "../../../modules/oci/base"
  compartment_ocid = var.compartment_ocid
  vcn_cidr         = "10.0.0.0/16"
}

module "k3s_compute" {
  source           = "../../../modules/oci/k3s_cluster"
  compartment_ocid = var.compartment_ocid
  vcn_id           = module.oci_infrastructure.vcn_id
  ssh_public_key   = var.ssh_public_key
  local_ip         = var.local_ip
  ssh_private_key         = var.ssh_private_key
  infisical_client_id     = var.infisical_client_id
  infisical_client_secret = var.infisical_client_secret
}

module "external_data_services" {
  source             = "../../../modules/external_data"
  neon_org_id = var.neon_org_id
  aiven_project_name = var.aiven_project_name
}