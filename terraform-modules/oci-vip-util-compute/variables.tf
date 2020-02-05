# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.




variable "default_compartment_id" {}

// naming convension
variable "names_prefix" {}
variable "defined_tags" {}
variable "freeform_tags" {}

# OCI VIP Instances

variable "ssh_private_key_path" {}
variable "ssh_public_key_path" {}
variable "image_name" {}
variable "nsg_ids" {
  type = list
}

variable "oci_vip_subnet" {}

variable "provision_util_node" {
  type = bool
}
variable "assign_public_ip" {}
