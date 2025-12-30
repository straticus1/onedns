# adsdnsgo - OCI Infrastructure
# Deploys DNS debugging tool to Oracle Cloud Always Free tier

terraform {
  required_version = ">= 1.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# Random suffix for unique naming
resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  name_prefix = "adsdnsgo-${random_id.suffix.hex}"
  common_tags = {
    "Project"     = "adsdnsgo"
    "Environment" = var.environment
    "ManagedBy"   = "Terraform"
    "CreatedAt"   = timestamp()
  }
}

# Data sources
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "arm_ol8" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# VCN
resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_ocid
  display_name   = "${local.name_prefix}-vcn"
  cidr_blocks    = [var.vcn_cidr]
  dns_label      = "adsdnsgo"

  freeform_tags = local.common_tags
}

# Internet Gateway
resource "oci_core_internet_gateway" "main" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${local.name_prefix}-igw"
  enabled        = true

  freeform_tags = local.common_tags
}

# Route Table
resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${local.name_prefix}-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.main.id
  }

  freeform_tags = local.common_tags
}

# Security List
resource "oci_core_security_list" "main" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${local.name_prefix}-sl"

  # Egress - allow all outbound
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # Ingress - SSH
  ingress_security_rules {
    protocol = "6" # TCP
    source   = var.allowed_ssh_cidr
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Ingress - HTTP
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }

  # Ingress - HTTPS
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }

  # Ingress - API (5000)
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 5000
      max = 5000
    }
  }

  # Ingress - ICMP (ping)
  ingress_security_rules {
    protocol = "1" # ICMP
    source   = "0.0.0.0/0"
  }

  freeform_tags = local.common_tags
}

# Public Subnet
resource "oci_core_subnet" "public" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.main.id
  display_name      = "${local.name_prefix}-public-subnet"
  cidr_block        = var.public_subnet_cidr
  route_table_id    = oci_core_route_table.public.id
  security_list_ids = [oci_core_security_list.main.id]
  dns_label         = "public"

  freeform_tags = local.common_tags
}

# Compute Instance (Always Free ARM)
resource "oci_core_instance" "adsdnsgo" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = "${local.name_prefix}-server"
  shape               = var.instance_shape

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_memory_gb
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.arm_ol8.images[0].id
    boot_volume_size_in_gbs = var.boot_volume_size_gb
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    display_name     = "${local.name_prefix}-vnic"
    assign_public_ip = true
    hostname_label   = "adsdnsgo"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {
      hostname = "adsdnsgo"
    }))
  }

  freeform_tags = local.common_tags
}

# API Key Generation
resource "random_password" "api_key" {
  length  = 64
  special = false
}

resource "random_uuid" "api_key_id" {}

# Object Storage Bucket for backups
resource "oci_objectstorage_bucket" "backups" {
  compartment_id = var.compartment_ocid
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = "${local.name_prefix}-backups"
  access_type    = "NoPublicAccess"

  freeform_tags = local.common_tags
}

data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.compartment_ocid
}

# Outputs
output "instance_public_ip" {
  description = "Public IP of the adsdnsgo server"
  value       = oci_core_instance.adsdnsgo.public_ip
}

output "instance_id" {
  description = "OCID of the compute instance"
  value       = oci_core_instance.adsdnsgo.id
}

output "vcn_id" {
  description = "OCID of the VCN"
  value       = oci_core_vcn.main.id
}

output "api_key" {
  description = "Generated API key for adsdnsgo"
  value       = random_password.api_key.result
  sensitive   = true
}

output "api_key_id" {
  description = "API key ID"
  value       = random_uuid.api_key_id.result
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = "ssh opc@${oci_core_instance.adsdnsgo.public_ip}"
}

output "api_endpoint" {
  description = "API endpoint URL"
  value       = "http://${oci_core_instance.adsdnsgo.public_ip}:5000"
}

output "backup_bucket" {
  description = "Object storage bucket for backups"
  value       = oci_objectstorage_bucket.backups.name
}

# Generate ansible inventory
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory/oci-hosts.yml"
  content  = <<-EOT
---
all:
  hosts:
    adsdnsgo:
      ansible_host: ${oci_core_instance.adsdnsgo.public_ip}
      ansible_user: opc
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
      api_key: ${random_password.api_key.result}
      api_key_id: ${random_uuid.api_key_id.result}
      instance_id: ${oci_core_instance.adsdnsgo.id}
      backup_bucket: ${oci_objectstorage_bucket.backups.name}
EOT
}

# Generate API key JSON for aeims integration
resource "local_file" "api_key_json" {
  filename = "${path.module}/../api-key.json"
  content  = <<-EOT
{
  "version": "1.0",
  "service": "adsdnsgo",
  "provider": "oci",
  "endpoint": "http://${oci_core_instance.adsdnsgo.public_ip}:5000",
  "api_key_id": "${random_uuid.api_key_id.result}",
  "api_key": "${random_password.api_key.result}",
  "instance_id": "${oci_core_instance.adsdnsgo.id}",
  "region": "${var.region}",
  "created_at": "${timestamp()}",
  "capabilities": [
    "dns_query",
    "dns_debug",
    "dnssec_validation",
    "spf_check",
    "dkim_check",
    "dmarc_check",
    "zone_validation",
    "dnsscience_integration"
  ]
}
EOT
}
