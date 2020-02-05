# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


#############################
# tenancy details
#############################

# Get this from the bottom of the OCI screen (after logging in, after Tenancy ID: heading)
variable "tenancy_id" {
  description = "Get this from the bottom of the OCI screen (after logging in, after Tenancy ID: heading)"
}

# Get this from OCI > Identity > Users (for your user account)
variable "user_id" {
  description = "Get this from OCI > Identity > Users (for your user account)"
}

# the fingerprint can be gathered from your user account (OCI > Identity > Users > click your username > API Keys fingerprint (select it, copy it and paste it below))
variable "fingerprint" {
  description = "The fingerprint can be gathered from your user account (OCI > Identity > Users > click your username > API Keys fingerprint (select it, copy it and paste it below))"
}

# this is the full path on your local system to the private key used for the API key pair
variable "private_key_path" {
  description = "This is the full path on your local system to the private key used for the API key pair"
}

# region (us-phoenix-1, ca-toronto-1, etc)
variable "region" {
  default     = "eu-frankfurt-1"
  description = "region (us-phoenix-1, ca-toronto-1, etc)"
}

# default compartment 
variable "default_compartment_id" {
  description = "default compartment OCID"
}

# Compartment where the IAM artifacts will be created - if null then default_compartment_id will be used
variable "iam_compartment_id" {
  description = "Compartment where the IAM artifacts will be created - if null then default_compartment_id will be used"
}

#############################
# naming convension
#############################

# the prefix that will be used for all the names of the OCI artifacts that this automation will provision
variable "names_prefix" {
  type        = string
  default     = "oci-vip-nginx"
  description = "the prefix that will be used for all the names of the OCI artifacts that this automation will provision"
}

# the defined tags to be used for all the artifacts that this automation will provision
variable "defined_tags" {
  type        = map(string)
  description = "the defined tags to be used for all the artifacts that this automation will provision"
}

# the freeform tags to be used for all the artifacts that this automation will provision
variable "freeform_tags" {
  type        = map(string)
  default     = { "Solution" = "Oracle Cloud Infrastructure SDF Solutions - Virtual Floating IP(VIP)" }
  description = "the freeform tags to be used for all the artifacts that this automation will provision"
}

#############################
# volumes - block storage
#############################

# The specific block volumes compartment id. If this is null then the default, project level compartment_id will be used.
variable "block_storage_compartment_id" {
  description = "The specific block volumes compartment id. If this is null then the default, project level compartment_id will be used."
}

# The aditional block volumes mount point
variable "aditional_block_volume_mount_point" {
  type        = string
  default     = "/u01"
  description = "The aditional block volumes mount point"
}

# The aditional block volumes size
variable "aditional_block_volume_size" {
  type        = number
  default     = 50
  description = "The aditional block volumes size"
}

# The aditional block volumes backup policy: Bronze, Silver or Gold. Default = Bronze. Null = Bronze
variable "volumes_backup_policy" {
  type        = string
  default     = "Bronze"
  description = "The aditional block volumes backup policy: Bronze, Silver or Gold. Default = Bronze. Null = Bronze"
}

#############################
# OCI VIP network
#############################

# The specific network compartment id. If this is null then the default, project level compartment_id will be used.
variable "network_compartment_id" {
  description = "The specific network compartment id. If this is null then the default, project level compartment_id will be used."
}

# the VCN id where the VIP network components will be provisioned
variable "vcn_id" {
  description = "The VCN id where the VIP network components will be provisioned"
}

# VIP subnet CIDR
variable "oci_vip_subnet_cidr" {
  type        = string
  default     = "10.0.80.0/24"
  description = "VIP subnet CIDR"
}

# VIP subnet DHCP options
variable "dhcp_options" {
  type = object({
    oci_vip_dhcp_option = object({
      server_type        = string,
      search_domain_name = string,
      forwarder_1_ip     = string,
      forwarder_2_ip     = string,
      forwarder_3_ip     = string
    })
  })
  default = {
    oci_vip_dhcp_option = {
      server_type        = "VcnLocalPlusInternet"
      search_domain_name = "DomainNameServer"
      forwarder_1_ip     = null
      forwarder_2_ip     = null
      forwarder_3_ip     = null
    }
  }
  description = "VIP subnet DHCP options"
}

# The route table attached to the VIP subnet. Configuration supports both public internet routes and private routes
variable "oci_vip_route_table" {
  type = object({
    route_rules = list(object({
      # route to public internet ("0.0.0.0/0") or to private destination
      dst      = string,
      dst_type = string,
      # next hop can be an Internet Gateway or other Gateway(ex. DRG)
      next_hop_id = string
    }))
  })
  default = {
    route_rules = [{
      dst         = "0.0.0.0/0",
      dst_type    = "CIDR_BLOCK",
      next_hop_id = "ocid1.internetgateway.XXXXXXX"
    }]
  }
  description = "The route table attached to the VIP subnet. Configuration supports both public internet routes and private routes"
}

# option for having a public and private VIP or just a private VIP
variable "assign_public_ip" {
  type        = bool
  default     = true
  description = "Option for having a public and private VIP or just a private VIP"
}

#############################
# File System Details
#############################

# The specific FSS compartment id. If this is null then the default, project level compartment_id will be used.
variable "fss_compartment_id" {
  description = "The specific FSS compartment id. If this is null then the default, project level compartment_id will be used."
}

# The FSS configuration. If null(file_system = null) then no FSS artifacts will not be configured
variable "file_system" {
  type = object({
    # the File Sytem and mount target AD - AD number
    availability_domain = number
    export_path         = string
  })
  default = {
    availability_domain = 1
    export_path         = "/u02"
  }
  description = "The FSS configuration. If null(file_system = null) then no FSS artifacts will not be configured"
}

# the folder(mount point) where the FSS NFS share will be mounted
variable "fss_mount_point" {
  type        = string
  default     = "/u02"
  description = "The folder(mount point) where the FSS NFS share will be mounted"
}

#############################
# OCI VIP Instances
#############################

# The specific compute compartment id. If this is null then the default, project level compartment_id will be used.
variable "compute_compartment_id" {
  description = "The specific compute compartment id. If this is null then the default, project level compartment_id will be used."
}

# The number of cluster nodes to be provisioned
variable "cluster_size" {
  type        = number
  default     = 6
  description = "The number of cluster nodes to be provisioned"
}

# Compute instances ssh public key
variable "ssh_private_key_path" {
  description = "Compute instances ssh public key"
}

# Compute instances ssh private key
variable "ssh_public_key_path" {
  description = "Compute instances ssh private key"
}

# The name of the shape to be used for all the provisioned compute instances. The automation will automatically figure out the OCID for the spaecific shape name in the target region.
variable "shape" {
  type        = string
  default     = "VM.Standard2.1"
  description = "The name of the shape to be used for all the provisioned compute instances. The automation will automatically figure out the OCID for the spaecific shape name in the target region."
}

# The name of the image to be used for all the provisioned compute instances. The automation will automatically figure out the OCID for the specific image name in the target region.
variable "image_name" {
  type        = string
  default     = "Oracle-Linux-7.7-2019.10.19-0"
  description = "The name of the image to be used for all the provisioned compute instances. The automation will automatically figure out the OCID for the specific image name in the target region."
}

# VIP instances configuration

# Accepted values: ["Apache", "Nginx"] 
variable "keepalived_check" {
  type        = string
  default     = "Nginx"
  description = "Accepted values: [Apache, Nginx]"
}

# Keepalived check script
# Only 2 values are accepted:
# - "'/usr/sbin/pidof httpd'"
# - "'/usr/sbin/pidof nginx'"
variable "install_product" {
  type        = string
  default     = "'/usr/sbin/pidof nginx'"
  description = "Keepalived check script. Only 2 values are accepted: ['/usr/sbin/pidof httpd', '/usr/sbin/pidof nginx']"
}

#############################
# OCI VIP Util Nodes
#############################

# Option to have an util compute node provisioned or not.
variable "provision_util_node" {
  type        = bool
  default     = true
  description = "Option to have an util compute node provisioned or not."
}