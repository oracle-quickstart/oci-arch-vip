# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


module "oci_block_storage_service" {

  source                     = "github.com/oracle-terraform-modules/terraform-oci-tdf-block-storage.git?ref=v0.1.5"
  default_compartment_id     = var.default_compartment_id
  default_ad                 = 0
  default_size_in_gbs        = 50
  default_backup_policy_name = "Bronze"
  default_defined_tags       = {}
  default_freeform_tags      = {}


  vols = {}
  # crete one volume group per AD
  vol_grps = { for ad_id in range(var.cluster_size >= length(data.oci_identity_availability_domains.availability_domains.availability_domains) ? length(data.oci_identity_availability_domains.availability_domains.availability_domains) : var.cluster_size) :
    "${var.names_prefix}-vol-grp-ad${ad_id + 1}" => {
      compartment_id = var.default_compartment_id
      ad             = ad_id
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      # add both boot and additional block volumes for the VIP VMs that are in the same AD
      ext_vol_ids = concat([for blk_vol in var.block_volumes : blk_vol.id if blk_vol.availability_domain == data.oci_identity_availability_domains.availability_domains.availability_domains[ad_id].name], var.instances != null ? [for inst in var.instances : inst.boot_volume_id if inst.availability_domain == data.oci_identity_availability_domains.availability_domains.availability_domains[ad_id].name] : [])
    }
  }
}

data "oci_identity_availability_domains" "availability_domains" {
  #Required
  compartment_id = var.tenancy_compartment_id
}