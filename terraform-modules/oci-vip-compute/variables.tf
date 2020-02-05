# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



variable "default_compartment_id" {}

variable "tenancy_compartment_id" {}

variable "cluster_size" {}

// naming convension
variable "names_prefix" {}
variable "defined_tags" {}
variable "freeform_tags" {}

# OCI VIP Instances

variable "ssh_private_key_path" {}
variable "ssh_public_key_path" {}
variable "shape" {}
variable "image_name" {}
variable "nsg_ids" {
  type = list
}

variable "block_volumes" {
  type = list
}
variable "volumes_backup_policy" {}

# OCI VIP Shared Storage

variable "nfs_mount" {}
variable "nfs_mount_point" {}
variable "file_system_config" {}

# VIP instances configuration

variable "keepalived_check" {}
variable "install_product" {}

#neworking
variable "oci_vip_subnet" {}
variable "oci_vip_subnet_cidr" {}
variable "assign_public_ip" {}





