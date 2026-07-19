provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid    = var.user_ocid
  fingerprint  = var.fingerprint
  private_key  = var.private_key
  region       = var.region
}

module "oci_infrastructure" {
  source           = "../../modules/oci_base"
  compartment_ocid = var.compartment_ocid
  vcn_cidr         = "10.0.0.0/16"
}
