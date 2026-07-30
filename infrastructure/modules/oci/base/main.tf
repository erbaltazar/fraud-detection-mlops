# infrastructure/modules/oci_base/main.tf

resource "oci_core_vcn" "mlops_vcn" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = [var.vcn_cidr]
  display_name   = "mlops-production-vcn"
  dns_label      = "mlops"
}

resource "oci_core_internet_gateway" "mlops_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.mlops_vcn.id
  enabled        = true
  display_name   = "mlops-internet-gateway"
}

resource "oci_core_default_route_table" "mlops_default_rt" {
  manage_default_resource_id = oci_core_vcn.mlops_vcn.default_route_table_id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.mlops_igw.id
  }
}
