# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



locals {
  tcp_protocol  = "6"
  icmp_protocol = "1"
  udp_protocol  = "17"
  vrrp_protocol = "112"
  all_protocols = "all"
  anywhere      = "0.0.0.0/0"

  // general network security groups for OCI VIP 
  oci-vip-nsg = { "${var.names_prefix}-nsg" = {
    "${var.names_prefix}-nsg" = {
      compartment_id = null
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      ingress_rules = [
        {
          description = "ingress from anywhere over TCP22"
          stateless   = false
          protocol    = local.tcp_protocol
          src         = local.anywhere
          src_type    = "CIDR_BLOCK"
          src_port    = null
          dst_port = {
            min = "22"
            max = "22"
          }
          icmp_code = null
          icmp_type = null
        },
        {
          description = "ingress from anywhere over TCP80"
          stateless   = false
          protocol    = local.tcp_protocol
          src         = local.anywhere
          src_type    = "CIDR_BLOCK"
          src_port    = null
          dst_port = {
            min = "80"
            max = "80"
          }
          icmp_code = null
          icmp_type = null
        },
        {
          description = "ingress from anywhere over TCP443"
          stateless   = false
          protocol    = local.tcp_protocol
          src         = local.anywhere
          src_type    = "CIDR_BLOCK"
          src_port    = null
          dst_port = {
            min = "443"
            max = "443"
          }
          icmp_code = null
          icmp_type = null
        },
        {
          description = "ingress ICMP"
          stateless   = false
          protocol    = local.icmp_protocol
          src         = var.oci_vip_subnet_cidr
          src_type    = "CIDR_BLOCK"
          src_port    = null
          dst_port    = null
          icmp_code   = null
          icmp_type   = null
        },
        {
          description = "ingress VRRP"
          stateless   = false
          protocol    = local.vrrp_protocol
          src         = var.oci_vip_subnet_cidr
          src_type    = "CIDR_BLOCK"
          src_port    = null
          dst_port    = null
          icmp_code   = null
          icmp_type   = null
        }
      ]
      egress_rules = [
        {
          description = "egress to anywhere over TCP"
          stateless   = false
          protocol    = local.tcp_protocol
          dst         = local.anywhere
          dst_type    = "CIDR_BLOCK"
          src_port    = null
          dst_port    = null
          icmp_code   = null
          icmp_type   = null
        },
        {
          description = "egress to local subnet over ICMP"
          stateless   = false
          protocol    = local.icmp_protocol
          dst         = var.oci_vip_subnet_cidr
          dst_type    = "CIDR_BLOCK"
          src_port    = null
          dst_port    = null
          icmp_code   = null
          icmp_type   = null
        },
        {
          description = "egress to local subnet over VRRP"
          stateless   = false
          protocol    = local.vrrp_protocol
          dst         = var.oci_vip_subnet_cidr
          dst_type    = "CIDR_BLOCK"
          src_port    = null
          dst_port    = null
          icmp_code   = null
          icmp_type   = null
        }
      ]
    }
    }
  }

  // general network security groups for util OCI VIP VM

  oci-vip-util-nsg = { "${var.names_prefix}-util-nsg" = var.provision_util_node == false ? {} : {
    "${var.names_prefix}-util-nsg" = {
      compartment_id = null
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      ingress_rules = [
        {
          description = "ingress from anywhere over TCP22"
          stateless   = false
          protocol    = local.tcp_protocol
          src         = local.anywhere
          src_type    = "CIDR_BLOCK"
          src_port    = null
          dst_port = {
            min = "22"
            max = "22"
          }
          icmp_code = null
          icmp_type = null
        },
        {
          description = "ingress ICMP"
          stateless   = false
          protocol    = local.icmp_protocol
          src         = var.oci_vip_subnet_cidr
          src_type    = "CIDR_BLOCK"
          src_port    = null
          dst_port    = null
          icmp_code   = null
          icmp_type   = null
        }
      ]
      egress_rules = [
        {
          description = "egress to anywhere over TCP"
          stateless   = false
          protocol    = local.tcp_protocol
          dst         = local.anywhere
          dst_type    = "CIDR_BLOCK"
          src_port    = null
          dst_port    = null
          icmp_code   = null
          icmp_type   = null
        },
        {
          description = "egress to local subnet over ICMP"
          stateless   = false
          protocol    = local.icmp_protocol
          dst         = var.oci_vip_subnet_cidr
          dst_type    = "CIDR_BLOCK"
          src_port    = null
          dst_port    = null
          icmp_code   = null
          icmp_type   = null
        }
      ]
    }
    }
  }

  # fss sec list

  fss_sec_list = var.file_system == null ? {
    "${var.names_prefix}-fss-sec-list" = {
      compartment_id = null
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      ingress_rules  = []
      egress_rules   = []
    }
    } : {
    "${var.names_prefix}-fss-sec-list" = {
      compartment_id = null
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      ingress_rules = [
        {
          description = "FSS TCP ingress 2048 - 2050"
          stateless   = false
          protocol    = local.tcp_protocol
          src         = var.oci_vip_subnet_cidr
          src_type    = "CIDR_BLOCK"
          src_port    = null
          dst_port = {
            min = "2048"
            max = "2050"
          }
          icmp_code = null
          icmp_type = null
        },
        {
          description = "FSS TCP ingress 111"
          stateless   = false
          protocol    = local.tcp_protocol
          src         = var.oci_vip_subnet_cidr
          src_type    = "CIDR_BLOCK"
          src_port    = null
          dst_port = {
            min = "111"
            max = "111"
          }
          icmp_code = null
          icmp_type = null
        },
        {
          description = "FSS UDP ingress 2048"
          stateless   = false
          protocol    = local.udp_protocol
          src         = var.oci_vip_subnet_cidr
          src_type    = "CIDR_BLOCK"
          src_port    = null
          dst_port = {
            min = "2048"
            max = "2048"
          }
          icmp_code = null
          icmp_type = null
        },
        {
          description = "FSS UDP ingress 2048"
          stateless   = false
          protocol    = local.udp_protocol
          src         = var.oci_vip_subnet_cidr
          src_type    = "CIDR_BLOCK"
          src_port    = null
          dst_port = {
            min = "111"
            max = "111"
          }
          icmp_code = null
          icmp_type = null
      }]
      egress_rules = [
        {
          description = "FSS TCP egress 2048-2050"
          stateless   = false
          protocol    = local.tcp_protocol
          dst         = var.oci_vip_subnet_cidr
          dst_type    = "CIDR_BLOCK"
          src_port = {
            min = 2048
            max = 2050
          }
          dst_port  = null
          icmp_type = null
          icmp_code = null
        },
        {
          description = "FSS TCP egress 111"
          stateless   = false
          protocol    = local.tcp_protocol
          dst         = var.oci_vip_subnet_cidr
          dst_type    = "CIDR_BLOCK"
          src_port = {
            min = 111
            max = 111
          }
          dst_port  = null
          icmp_type = null
          icmp_code = null
        },
        {
          description = "FSS UDP egress 111"
          stateless   = false
          protocol    = local.udp_protocol
          dst         = var.oci_vip_subnet_cidr
          dst_type    = "CIDR_BLOCK"
          src_port = {
            min = 111
            max = 111
          }
          dst_port  = null
          icmp_type = null
          icmp_code = null
      }]
    }
  }
}

module "oci_network" {
  source = "github.com/oracle-terraform-modules/terraform-oci-tdf-network.git?ref=v0.9.7"


  default_compartment_id = var.default_compartment_id

  existing_vcn_id = var.vcn_id
  vcn_options     = null

  create_igw   = false
  create_svcgw = false
  create_natgw = false
  create_drg   = false

  route_tables = {
    "${var.names_prefix}_route_table" = {
      compartment_id = null
      defined_tags   = var.defined_tags
      freeform_tags  = var.freeform_tags
      route_rules    = var.oci_vip_route_table.route_rules
    }
  }

  dhcp_options = {
    "${var.names_prefix}_dhcp_option" = {
      compartment_id     = null
      server_type        = var.dhcp_options.oci_vip_dhcp_option.server_type
      search_domain_name = var.dhcp_options.oci_vip_dhcp_option.search_domain_name
      forwarder_1_ip     = var.dhcp_options.oci_vip_dhcp_option.forwarder_1_ip
      forwarder_2_ip     = var.dhcp_options.oci_vip_dhcp_option.forwarder_2_ip
      forwarder_3_ip     = var.dhcp_options.oci_vip_dhcp_option.forwarder_3_ip
    }
  }
}

module "oci_vip_security_policies" {
  source = "github.com/oracle-terraform-modules/terraform-oci-tdf-network-security.git?ref=v0.9.7"

  default_compartment_id = var.default_compartment_id
  vcn_id                 = var.vcn_id

  nsgs = local.oci-vip-nsg["${var.names_prefix}-nsg"]
}

module "oci_vip_util_security_policies" {
  source = "github.com/oracle-terraform-modules/terraform-oci-tdf-network-security.git?ref=v0.9.7"

  default_compartment_id = var.default_compartment_id
  vcn_id                 = var.vcn_id

  nsgs = local.oci-vip-util-nsg["${var.names_prefix}-util-nsg"]

}

module "oci_vip_fss_sec_list" {
  source = "github.com/oracle-terraform-modules/terraform-oci-tdf-network-security.git?ref=v0.9.7"

  default_compartment_id = var.default_compartment_id
  vcn_id                 = var.vcn_id

  security_lists = local.fss_sec_list
}

module "oci_subnets" {
  source                 = "github.com/oracle-terraform-modules/terraform-oci-tdf-subnet.git?ref=v0.9.6"
  default_compartment_id = var.default_compartment_id

  vcn_id   = var.vcn_id
  vcn_cidr = var.vcn_cidr


  subnets = {
    "${var.names_prefix}-subnet" = {
      compartment_id    = null
      defined_tags      = var.defined_tags
      freeform_tags     = var.freeform_tags
      dynamic_cidr      = false
      cidr              = var.oci_vip_subnet_cidr
      cidr_len          = null
      cidr_num          = null
      enable_dns        = true
      dns_label         = "${replace("${var.names_prefix}", "/[-| |T|Z|:]/", "")}"
      private           = ! (var.assign_public_ip)
      ad                = null
      dhcp_options_id   = module.oci_network.dhcp_options["${var.names_prefix}_dhcp_option"].id
      route_table_id    = module.oci_network.route_tables["${var.names_prefix}_route_table"].id
      security_list_ids = [data.oci_core_vcn.vcn.default_security_list_id, module.oci_vip_fss_sec_list.security_lists["${var.names_prefix}-fss-sec-list"].id]
    }
  }
}

data "oci_core_vcn" "vcn" {
  #Required
  vcn_id = var.vcn_id
}



