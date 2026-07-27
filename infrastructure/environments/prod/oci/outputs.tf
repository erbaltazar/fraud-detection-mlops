output "vcn_id" {
  value       = module.oci_infrastructure.vcn_id
  description = "The OCID of the generated Virtual Cloud Network"
}

output "k3s_server_ip" {
  value       = module.k3s_compute.k3s_public_ip
  description = "The public IP address required for remote terminal SSH access"
}