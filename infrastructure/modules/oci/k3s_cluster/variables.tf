variable "compartment_ocid" {
  description = "The OCID of the Oracle Cloud compartment"
  type        = string
}

variable "vcn_id" {
  description = "The dynamically generated VCN ID from the base module"
  type        = string
}

variable "subnet_cidr" {
  description = "The CIDR block for the K3s subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "ssh_public_key" {
  description = "The Ed25519 SSH public key for secure instance access"
  type        = string
}

variable "local_ip" {
  description = "Your specific public IP address for secure SSH and k3s API access (e.g., 203.0.113.50/32)"
  type        = string
}