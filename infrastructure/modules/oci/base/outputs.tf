output "vcn_id" {
  value       = oci_core_vcn.mlops_vcn.id
  description = "The OCID of the generated Virtual Cloud Network"
}