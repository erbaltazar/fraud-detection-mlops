data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

data "oci_core_images" "ubuntu_arm" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_security_list" "k3s_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = "k3s-security-list"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # SSH Access - Locked to your IP
  ingress_security_rules {
    source   = var.local_ip 
    protocol = "6" # TCP
    tcp_options {
      max = 22
      min = 22
    }
  }

  # K3s API Access - Locked to your IP
  ingress_security_rules {
    source   = var.local_ip 
    protocol = "6" # TCP
    tcp_options {
      max = 6443
      min = 6443
    }
  }
}

resource "oci_core_subnet" "k3s_subnet" {
  compartment_id    = var.compartment_ocid
  vcn_id            = var.vcn_id
  cidr_block        = var.subnet_cidr
  display_name      = "k3s-subnet"
  security_list_ids = [oci_core_security_list.k3s_security_list.id]
}

resource "oci_core_instance" "k3s_server" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "mlops-k3s-control-plane"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 2
    memory_in_gbs = 12
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.k3s_subnet.id
    display_name     = "primary-vnic"
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_arm.images[0].id
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    # Inject k3s installation script via cloud-init
    user_data = base64encode(<<-EOF
      #!/bin/bash
      curl -sfL https://get.k3s.io | sh -
    EOF
    )
  }
}