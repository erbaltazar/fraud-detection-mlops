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