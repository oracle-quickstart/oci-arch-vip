# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



locals {
  products                   = ["Apache", "Nginx"]
  install_product_validation = index(local.products, var.install_product)

  keepalived_checks           = ["'/usr/sbin/pidof httpd'", "'/usr/sbin/pidof nginx'"]
  keepalived_check_validation = index(local.keepalived_checks, var.keepalived_check)
}

module "oci-vip-network" {
  source = "./terraform-modules/oci-vip-network"

  # compartment
  default_compartment_id = var.network_compartment_id != null ? var.network_compartment_id : var.default_compartment_id

  # naming convensions
  names_prefix  = var.names_prefix
  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  # networking details
  vcn_id              = var.vcn_id
  vcn_cidr            = data.oci_core_vcn.vcn.cidr_block
  oci_vip_subnet_cidr = var.oci_vip_subnet_cidr
  oci_vip_route_table = var.oci_vip_route_table
  dhcp_options        = var.dhcp_options
  assign_public_ip    = var.assign_public_ip

  # OCI VIP Util Nodes
  provision_util_node = var.provision_util_node

  # OCI VIP FSS
  file_system = var.file_system

}

module "oci-vip-shared-storage" {

  source = "./terraform-modules/oci-vip-shared-storage"

  providers = {
    oci.custom_provider = "oci"
  }

  #compartment
  default_compartment_id = var.fss_compartment_id != null ? var.fss_compartment_id : var.default_compartment_id

  #naming convensions
  names_prefix  = var.names_prefix
  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags


  #networking
  oci_vip_subnet = module.oci-vip-network.subnets["${var.names_prefix}-subnet"].id

  file_system = var.file_system
}

# create the aditional VMs block volumes

module "oci-vip-volumes" {

  source = "./terraform-modules/oci-vip-volumes"

  cluster_size                = var.cluster_size
  default_compartment_id      = var.block_storage_compartment_id != null ? var.block_storage_compartment_id : var.default_compartment_id
  names_prefix                = var.names_prefix
  volumes_backup_policy       = var.volumes_backup_policy
  aditional_block_volume_size = var.aditional_block_volume_size
  tenancy_compartment_id      = var.tenancy_id
  defined_tags                = var.defined_tags
  freeform_tags               = var.freeform_tags

}

module "oci-vip-compute" {
  source = "./terraform-modules/oci-vip-compute"

  default_compartment_id = var.compute_compartment_id != null ? var.compute_compartment_id : var.default_compartment_id
  tenancy_compartment_id = var.tenancy_id

  cluster_size          = var.cluster_size
  names_prefix          = var.names_prefix
  ssh_private_key_path  = var.ssh_private_key_path
  ssh_public_key_path   = var.ssh_public_key_path
  shape                 = var.shape
  image_name            = var.image_name
  volumes_backup_policy = var.volumes_backup_policy
  oci_vip_subnet        = module.oci-vip-network.subnets["${var.names_prefix}-subnet"].id
  oci_vip_subnet_cidr   = module.oci-vip-network.subnets["${var.names_prefix}-subnet"].cidr_block
  assign_public_ip      = var.assign_public_ip
  nsg_ids               = [module.oci-vip-network.oci_vip_nsg_rules[0].network_security_group_id]
  block_volumes = [for s in {
    for i in range(var.cluster_size) : "${var.names_prefix}-${i + 1}-volume01" => {
      volume = "${var.names_prefix}-${i + 1}-volume01",
      details = {
        volume_id        = contains(keys(module.oci-vip-volumes.block_volumes), "${var.names_prefix}-${i + 1}-volume01") ? module.oci-vip-volumes.block_volumes["${var.names_prefix}-${i + 1}-volume01"].id : ""
        attachment_type  = "iscsi",
        volume_mount_dir = var.aditional_block_volume_mount_point
      }
    }
  } : list(s)]
  keepalived_check = var.keepalived_check
  install_product  = var.install_product
  defined_tags     = var.defined_tags
  freeform_tags    = var.freeform_tags

  # OCI VIP Shared Storage
  nfs_mount          = var.file_system != null ? "${module.oci-vip-shared-storage.file_system.mount_targets.fs1_mt1.hostname_label}.${data.oci_core_subnet.vip_subnet[0].subnet_domain_name}:${module.oci-vip-shared-storage.file_system.mount_targets.fs1_mt1.export_sets.fs1_mt1-export-set.exports[0].path}" : null
  nfs_mount_point    = var.fss_mount_point
  file_system_config = var.file_system
}

module "oci-vip-util-compute" {
  source = "./terraform-modules/oci-vip-util-compute"

  default_compartment_id = var.compute_compartment_id != null ? var.compute_compartment_id : var.default_compartment_id
  provision_util_node    = var.provision_util_node
  names_prefix           = var.names_prefix
  ssh_private_key_path   = var.ssh_private_key_path
  ssh_public_key_path    = var.ssh_public_key_path
  image_name             = var.image_name
  oci_vip_subnet         = module.oci-vip-network.subnets["${var.names_prefix}-subnet"].id
  assign_public_ip       = var.assign_public_ip
  nsg_ids                = var.provision_util_node == false ? [] : [module.oci-vip-network.oci_vip_util_nsg_rules[0].network_security_group_id]
  defined_tags           = var.defined_tags
  freeform_tags          = var.freeform_tags
}

# create one volume group per region AD and add to it the VIP instances block and boot volumes  

module "oci-vip-vol-groups" {

  source = "./terraform-modules/oci-vip-vol-groups"

  default_compartment_id = var.compute_compartment_id != null ? var.compute_compartment_id : var.default_compartment_id
  tenancy_compartment_id = var.tenancy_id
  names_prefix           = var.names_prefix
  block_volumes          = module.oci-vip-volumes.block_volumes
  instances              = module.oci-vip-compute.vip_instances.instance
  defined_tags           = var.defined_tags
  freeform_tags          = var.freeform_tags
  cluster_size           = var.cluster_size
}

module "oci-vip-iam" {
  source = "./terraform-modules/oci-vip-iam"

  // IAM Details

  providers = {
    oci.oci_home = "oci.oci_home"
  }

  default_compartment_id = var.iam_compartment_id != null ? var.iam_compartment_id : var.default_compartment_id
  tenancy_compartment_id = var.tenancy_id

  // naming convension
  names_prefix  = "${var.names_prefix}"
  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  // instances
  instances_ids = [for instance in module.oci-vip-compute.vip_instances.instance : instance.id]
}


