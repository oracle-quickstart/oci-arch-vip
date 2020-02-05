# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



module "oci_instances" {
  source = "github.com/oracle-terraform-modules/terraform-oci-tdf-compute-instance.git?ref=v0.10.2"

  default_compartment_id = var.default_compartment_id

  instances = var.provision_util_node == false ? {} : {
    "${var.names_prefix}-util-inst" = {
      ad                     = 0
      compartment_id         = var.default_compartment_id
      shape                  = "VM.Standard2.1"
      subnet_id              = var.oci_vip_subnet
      is_monitoring_disabled = null
      assign_public_ip       = var.assign_public_ip
      vnic_defined_tags      = var.defined_tags
      vnic_display_name      = "${var.names_prefix}-util-inst-vnic-01"
      vnic_freeform_tags     = var.freeform_tags
      nsg_ids                = var.nsg_ids
      private_ip             = null
      skip_src_dest_check    = null
      defined_tags           = var.defined_tags
      extended_metadata      = null
      fault_domain           = "FAULT-DOMAIN-1"
      freeform_tags          = var.freeform_tags
      hostname_label         = "${var.names_prefix}-util-inst"
      ipxe_script            = null
      pv_encr_trans_enabled  = null
      ssh_authorized_keys    = ["${var.ssh_public_key_path}"]
      ssh_private_keys       = ["${var.ssh_private_key_path}"]
      user_data              = null
      source_id              = null
      image_name             = var.image_name
      source_type            = null
      mkp_image_name         = null
      mkp_image_name_version = null
      boot_vol_size_gbs      = null
      kms_key_id             = null
      preserve_boot_volume   = null
      instance_timeout       = null
      sec_vnics              = null
      block_volumes          = null
      mount_blk_vols         = false
      cons_conn_create       = null
      cons_conn_def_tags     = null
      cons_conn_free_tags    = null
      bastion_ip             = null
    }
  }
}
