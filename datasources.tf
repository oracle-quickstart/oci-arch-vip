# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



data "oci_core_volume_backup_policies" "volume_backup_policies" {
}

data "oci_core_volumes" "volumes" {
  for_each = module.oci-vip-vol-groups.volume_groups

  #Required
  compartment_id = each.value.compartment_id

  #Optional
  availability_domain = each.value.availability_domain
  volume_group_id     = each.value.id
}

data "oci_core_boot_volumes" "boot_volumes" {
  for_each = module.oci-vip-vol-groups.volume_groups

  #Required
  compartment_id = each.value.compartment_id

  #Optional
  availability_domain = each.value.availability_domain
  volume_group_id     = each.value.id
}

data "oci_core_vcn" "vcn" {
  #Required
  vcn_id = var.vcn_id
}

data "oci_core_security_lists" "security_lists" {
  for_each = { search = "search" }
  #Required
  compartment_id = var.default_compartment_id
  vcn_id         = var.vcn_id
}

data "oci_core_private_ip" "fss_private_ip" {
  count = var.file_system != null ? 1 : 0
  #Required
  private_ip_id = var.file_system != null ? module.oci-vip-shared-storage.file_system.mount_targets.fs1_mt1.private_ip_ids[0] : "0"
}

data "oci_core_subnet" "vip_subnet" {
  count = var.file_system != null ? 1 : 0
  #Required
  subnet_id = var.file_system != null ? module.oci-vip-shared-storage.file_system.mount_targets.fs1_mt1.subnet_id : "0"
}

data "oci_identity_region_subscriptions" "this" {
  tenancy_id = var.tenancy_id
}