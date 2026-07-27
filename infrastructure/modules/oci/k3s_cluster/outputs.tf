output "k3s_public_ip" {
  value       = oci_core_instance.k3s_server.public_ip
  description = "The public IP address of the provisioned k3s node"
}