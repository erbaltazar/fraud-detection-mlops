# infrastructure/modules/oci_base/variables.tf

variable "compartment_ocid" {
  description = "The OCID of the Oracle Cloud compartment"
  type        = string
}

variable "region" {
  description = "The OCI region to deploy into"
  type        = string
  default     = "ap-tokyo-1"
}

variable "vcn_cidr" {
  description = "The CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"
}