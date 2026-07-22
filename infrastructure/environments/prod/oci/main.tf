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

resource "oci_core_default_route_table" "mlops_default_rt" {
  manage_default_resource_id = oci_core_vcn.mlops_vcn.default_route_table_id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.mlops_igw.id
  }
}

# 4. Expose the VCN ID to the orchestrator
output "vcn_id" {
  value       = oci_core_vcn.mlops_vcn.id
  description = "The OCID of the generated Virtual Cloud Network"
}