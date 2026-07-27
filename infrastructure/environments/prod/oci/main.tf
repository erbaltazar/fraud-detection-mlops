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
}