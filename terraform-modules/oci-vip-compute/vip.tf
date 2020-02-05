# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



locals {
  instances_default_vnics = {
    for i in range(var.cluster_size) : "${var.names_prefix}-inst-${i + 1}" => {
      instance_id = module.oci_instances.instance["${var.names_prefix}-inst-${i + 1}"].id,
      "vnic_0_id" = {
      for v in data.oci_core_vnic_attachments.node_ens3_vnic_attachments : "vnic_0_id" => v.vnic_attachments[0].vnic_id if v.instance_id == module.oci_instances.instance["${var.names_prefix}-inst-${i + 1}"].id }["vnic_0_id"],
      "vnic_attachment_id" = {
      for v in data.oci_core_vnic_attachments.node_ens3_vnic_attachments : "vnic_attachment_id" => v.vnic_attachments[0].id if v.instance_id == module.oci_instances.instance["${var.names_prefix}-inst-${i + 1}"].id }["vnic_attachment_id"]
    }
  }
  oci_vip_instances_private_ips = [for i in range(var.cluster_size) : module.oci_instances.instance["${var.names_prefix}-inst-${i + 1}"].private_ip]
}

resource "oci_core_private_ip" "oci_private_vip" {
  #Required
  vnic_id = local.instances_default_vnics["${var.names_prefix}-inst-1"].vnic_0_id

  #Optional
  display_name   = "${lower(format("%.30s", format("%s%s", var.names_prefix, "-private-vip-ip")))}"
  hostname_label = "${lower(format("%.30s", format("%s%s", var.names_prefix, "-private-vip")))}"
  ip_address     = "${cidrhost(var.oci_vip_subnet_cidr, -2)}"
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
}

data "oci_core_vnic_attachments" "node_ens3_vnic_attachments" {
  #Required
  count          = var.cluster_size
  compartment_id = var.default_compartment_id

  #Optional
  instance_id = module.oci_instances.instance["${var.names_prefix}-inst-${count.index + 1}"].id
}

resource "oci_core_public_ip" "oci_public_vip" {
  #Required
  compartment_id = var.default_compartment_id
  lifetime       = "RESERVED"

  #Optional
  display_name  = "${lower(format("%.30s", format("%s%s", var.names_prefix, "-public-vip-ip")))}"
  private_ip_id = "${oci_core_private_ip.oci_private_vip.id}"
  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags
}

