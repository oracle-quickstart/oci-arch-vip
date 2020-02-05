# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



locals {

  #########################
  ## Networking Details
  #########################
  networking_details = {
    subnet = {
      for x in module.oci-vip-network.subnets : x.display_name => {
        ad            = x.availability_domain,
        defined_tags  = x.defined_tags,
        freeform_tags = x.freeform_tags,
        dhcp_options = { for dhcp in module.oci-vip-network.dhcp_options : dhcp.display_name => {
          state           = dhcp.state,
          options         = dhcp.options,
          dhcp_options_id = x.dhcp_options_id
          }
        },
        route_table = { for rt_table in module.oci-vip-network.route_tables : rt_table.display_name => {
          name           = rt_table.display_name,
          route_rules    = rt_table.route_rules,
          state          = rt_table.state,
          route_table_id = x.route_table_id
          }
        },
        security_list = merge({
          for default_sec_list in data.oci_core_security_lists.security_lists["search"].security_lists : default_sec_list.display_name => {
            security_list_id       = default_sec_list.id,
            egress_security_rules  = default_sec_list.egress_security_rules,
            ingress_security_rules = default_sec_list.ingress_security_rules
          } if default_sec_list.id == data.oci_core_vcn.vcn.default_security_list_id
          },
          {
            for sec_list in module.oci-vip-network.oci_vip_fss_sec_list : sec_list.display_name => {
              security_list_id       = sec_list.id
              egress_security_rules  = sec_list.egress_security_rules
              ingress_security_rules = sec_list.ingress_security_rules
            } if contains(tolist(x.security_list_ids), sec_list.id)
        })
        state = x.state,
        vcn = {
          vcn_id          = x.vcn_id,
          vcn_name        = data.oci_core_vcn.vcn.display_name,
          vcn_cidr        = data.oci_core_vcn.vcn.cidr_block,
          vcn_dns_lable   = data.oci_core_vcn.vcn.dns_label,
          vcn_domain_name = data.oci_core_vcn.vcn.vcn_domain_name,
        },
        name               = x.display_name,
        cidr_block         = x.cidr_block,
        dns_label          = x.dns_label,
        public_subnet      = ! (x.prohibit_public_ip_on_vnic),
        subnet_domain_name = x.subnet_domain_name,
        virtual_router_ip  = x.virtual_router_ip
      }
    },
    nsgs = {
      "${var.names_prefix}-nsg" = {
        name = "${var.names_prefix}-nsg",
        nsg_rules = [
          for y in module.oci-vip-network.oci_vip_nsg_rules : {
            description      = y.description,
            direction        = y.direction,
            destination_type = y.destination_type,
            destination      = y.destination,
            icmp_options     = y.icmp_options,
            is_valid         = y.is_valid,
            protocol         = y.protocol,
            source           = y.source,
            source_type      = y.source_type,
            stateless        = y.stateless,
            tcp_options      = y.tcp_options,
            udp_options      = y.udp_options
          }
      ] },
      "${var.names_prefix}-util-nsg" = {
        name = "${var.names_prefix}-util-nsg",
        nsg_rules = [
          for y in module.oci-vip-network.oci_vip_util_nsg_rules : {
            description      = y.description,
            direction        = y.direction,
            destination_type = y.destination_type,
            destination      = y.destination,
            icmp_options     = y.icmp_options,
            is_valid         = y.is_valid,
            protocol         = y.protocol,
            source           = y.source,
            source_type      = y.source_type,
            stateless        = y.stateless,
            tcp_options      = y.tcp_options,
            udp_options      = y.udp_options
          }
      ] }
    }
  }



  #########################
  ## Volumes Details
  #########################
  volumes = {
    block_volumes = {
      for x in module.oci-vip-volumes.block_volumes : x.display_name => {
        id            = x.id
        name          = x.display_name,
        ad            = x.availability_domain,
        size_in_gbs   = x.size_in_gbs,
        backup_policy = [for bkp in data.oci_core_volume_backup_policies.volume_backup_policies.volume_backup_policies : bkp.display_name if bkp.id == x.backup_policy_id][0],
        volume_group = {
          for vgrp in module.oci-vip-vol-groups.volume_groups : "volume_group" => {
            "${vgrp.display_name}" = vgrp.id
        } if contains([for volid in vgrp.volume_ids : volid], x.id) }["volume_group"]
      }
    },
    volume_groups = { for x in module.oci-vip-vol-groups.volume_groups : x.display_name => {
      id          = x.id
      name        = x.display_name,
      ad          = x.availability_domain,
      size_in_gbs = x.size_in_gbs,
      volumes = merge({
        for vol_key in keys({
          for volume in data.oci_core_volumes.volumes[x.display_name].volumes : volume.display_name => {
          "${volume.display_name}" = volume.id } }) : vol_key => {
          for volume in data.oci_core_volumes.volumes[x.display_name].volumes : volume.display_name => {
            "${volume.display_name}" = volume.id
          }
        }[vol_key][vol_key] }, {
        for boot_vol_key in keys({ for boot_volume in data.oci_core_boot_volumes.boot_volumes[x.display_name].boot_volumes : boot_volume.display_name => {
          "${boot_volume.display_name}" = boot_volume.id } }) : boot_vol_key => {
          for boot_volume in data.oci_core_boot_volumes.boot_volumes[x.display_name].boot_volumes : boot_volume.display_name => {
            "${boot_volume.display_name}" = boot_volume.id
          }
      }[boot_vol_key][boot_vol_key] })

      }
    }
  }

  #########################
  ## FileSystem
  #########################

  #fss = module.oci-vip-shared-storage.file_system
  fss = {
    mount_targets = {
      for mt_key, mt in module.oci-vip-shared-storage.file_system.mount_targets : mt_key => {
        availability_domain = mt.availability_domain,
        nfs_mount           = var.file_system != null ? "${mt.hostname_label}.${data.oci_core_subnet.vip_subnet[0].subnet_domain_name}:${mt.export_sets.fs1_mt1-export-set.exports[0].path}" : ""
        mt_private_ip       = var.file_system != null ? data.oci_core_private_ip.fss_private_ip[0].ip_address : ""
        fqdn                = var.file_system != null ? "${mt.hostname_label}.${data.oci_core_subnet.vip_subnet[0].subnet_domain_name}" : ""
        file_systems = {
          for fs_key, fs in module.oci-vip-shared-storage.file_system.file_systems : fs_key => {
            availability_domain = fs.availability_domain
          }
        }
        subnet = {
          "${var.file_system != null ? data.oci_core_subnet.vip_subnet[0].display_name : ""}" = var.file_system != null ? data.oci_core_subnet.vip_subnet[0].cidr_block : ""
        }
      }
    }
  }

  #########################
  ## Instances
  #########################

  instances = {
    vip_instances = {
      for x in module.oci-vip-compute.vip_instances.instance : x.display_name => {
        name         = x.display_name,
        ad           = x.availability_domain,
        fault_domain = x.fault_domain,
        private_ip   = x.private_ip,
        public_ip    = x.public_ip,
        shape        = x.shape
      }
    },
    public_vip           = module.oci-vip-compute.public_vip,
    private_vip          = module.oci-vip-compute.private_vip,
    private_vip_hostname = module.oci-vip-compute.private_vip_hostname,
    installed_product    = var.install_product == 0 ? "Apache" : "Nginx",
    prod_url             = module.oci-vip-compute.prod_url,
    vip_util_instances = {
      for x in module.oci-vip-util-compute.instances.instance : x.display_name => {
        name         = x.display_name,
        ad           = x.availability_domain,
        fault_domain = x.fault_domain,
        private_ip   = x.private_ip,
        public_ip    = x.public_ip,
        shape        = x.shape
      }
    }
  }

  #########################
  ## IAM Details
  #########################
  iam_details = {
    dynamic_groups = {
      for x in module.oci-vip-iam.DynamicGroups : x.name => {
        name          = x.name,
        id            = x.id,
        matching_rule = x.matching_rule
      }
    },
    policies = {
      for x in module.oci-vip-iam.Policies : x.name => {
        name       = x.name,
        id         = x.id,
        statements = x.statements
      }
    }
  }
}

#########################
## OCI VIP Details
#########################

output "oci_vip_details" {
  description = "The OCI VIP networking details"
  value = {
    networking_details = local.networking_details,
    volumes            = local.volumes,
    fss                = local.fss,
    instances          = local.instances,
    iam_details        = local.iam_details
  }
  depends_on = [module.oci-vip-vol-groups.volume_groups]
}


