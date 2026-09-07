provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid    = var.user_ocid
  fingerprint  = var.fingerprint
  private_key  = var.private_key
  region       = var.region
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

# 1. Authenticate with Infisical
provider "infisical" {
  host = "https://app.infisical.com"
  auth = {
    universal = {
      client_id     = var.infisical_client_id
      client_secret = var.infisical_client_secret
    }
  }
}

# 2. Fetch the Grafana secrets dynamically from the prod environment
data "infisical_secrets" "grafana_creds" {
  env_slug     = "prod"
  workspace_id = var.infisical_workspace_id
  folder_path  = "/"
}

# 3. Dynamically pull the K3s config for HCP Terraform
data "external" "kubeconfig" {
  program = [
    "bash", "-c",
    "printf '%s\\n' \"$1\" > /tmp/tf_key && chmod 600 /tmp/tf_key && ssh -i /tmp/tf_key -o StrictHostKeyChecking=no ubuntu@$2 'sudo cat /etc/rancher/k3s/k3s.yaml' | sed \"s/127.0.0.1/$2/g\" | jq -Rs '{config: .}'",
    "_",
    var.ssh_private_key,
    module.k3s_compute.k3s_public_ip
  ]
  
  depends_on = [module.k3s_compute]
}

locals {
  kubeconfig = yamldecode(data.external.kubeconfig.result.config)
}

provider "kubernetes" {
  host                   = local.kubeconfig.clusters[0].cluster.server
  cluster_ca_certificate = base64decode(local.kubeconfig.clusters[0].cluster["certificate-authority-data"])
  client_certificate     = base64decode(local.kubeconfig.users[0].user["client-certificate-data"])
  client_key             = base64decode(local.kubeconfig.users[0].user["client-key-data"])
}

provider "helm" {
  kubernetes {
    host                   = local.kubeconfig.clusters[0].cluster.server
    cluster_ca_certificate = base64decode(local.kubeconfig.clusters[0].cluster["certificate-authority-data"])
    client_certificate     = base64decode(local.kubeconfig.users[0].user["client-certificate-data"])
    client_key             = base64decode(local.kubeconfig.users[0].user["client-key-data"])
  }
}

# 4. Deploy the Observability Stack
module "observability" {
  source             = "../../../modules/k8s/observability"
  
  grafana_remote_url = data.infisical_secrets.grafana_creds.secrets["GRAFANA_REMOTE_URL"].value
  grafana_username   = data.infisical_secrets.grafana_creds.secrets["GRAFANA_USERNAME"].value
  grafana_api_token  = data.infisical_secrets.grafana_creds.secrets["GRAFANA_API_TOKEN"].value
  
  depends_on = [module.k3s_compute]
}