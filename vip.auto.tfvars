# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


#############################
# TENANCY DETAILS
#############################

# default compartment 
default_compartment_id = "<default_compartment_ocid>"

# iam compartment - if null then default_compartment_id will be used
iam_compartment_id = null

#############################
# naming convension
#############################

# the prefix that will be used for all the names of the OCI artifacts that this automation will provision
names_prefix = "oci-vip-nginx"

# the defined tags to be used for all the artifacts that this automation will provision
defined_tags = {}

# the freeform tags to be used for all the artifacts that this automation will provision
freeform_tags = {}

#############################
# volumes - block storage
#############################

# block storage compartment - if null then default_compartment_id will be used
block_storage_compartment_id = null

# The aditional block volumes backup policy: Bronze, Silver or Gold. Default = Bronze. Null = Bronze
volumes_backup_policy = null

# The aditional block volumes mount point
aditional_block_volume_mount_point = "/u01"

# The aditional block volumes size
aditional_block_volume_size = 55

#############################
# OCI VIP network
#############################

# The specific network compartment id. If this is null then the default, project level compartment_id will be used.
network_compartment_id = null

# the VCN id where the VIP network components will be provisioned
vcn_id = "<vcn-ocid>"

# the route table attached to the VIP subnet. Configuration supports both public internet routes and private routes
oci_vip_route_table = {
  route_rules = [{
    # route to public internet ("0.0.0.0/0") or to private destination
    dst      = "0.0.0.0/0"
    dst_type = "CIDR_BLOCK"
    # next hop can be an Internet Gateway or other Gateway(ex. DRG)
    next_hop_id = "<IG-OCID>"
  }]
}

# VIP subnet DHCP options
dhcp_options = {
  oci_vip_dhcp_option = {
    server_type        = "VcnLocalPlusInternet"
    search_domain_name = "DomainNameServer"
    forwarder_1_ip     = null
    forwarder_2_ip     = null
    forwarder_3_ip     = null
  }
}

# VIP subnet CIDR
oci_vip_subnet_cidr = "10.0.80.0/24"

# option for having a public and private VIP or just a private VIP
assign_public_ip = true

#############################
# File System Details
#############################

# The specific FSS compartment id. If this is null then the default, project level compartment_id will be used.
fss_compartment_id = null

# The FSS configuration. If null(file_system = null) then no FSS artifacts will not be configured
file_system = {
  # the File Sytem and mount target AD - AD number
  availability_domain = 1
  export_path         = "/u02"
}

# the folder(mount point) where the FSS NFS share will be mounted
fss_mount_point = "/u02"

#############################
# OCI VIP Instances
#############################

# The specific compute compartment id. If this is null then the default, project level compartment_id will be used.
compute_compartment_id = null

# The number of cluster nodes to be provisioned
cluster_size = 6

# Compute instances ssh public key
ssh_public_key_path = "<ssh-public-key>"

# Compute instances ssh private key
ssh_private_key_path = "<ssh-private-key>"

# The name of the shape to be used for all the provisioned compute instances. The automation will automatically figure out the OCID for the specific shape name in the target region.
shape = "VM.Standard2.1"

# The name of the image to be used for all the provisioned compute instances. The automation will automatically figure out the OCID for the specific image name in the target region.
image_name = "Oracle-Linux-7.7-2020.01.28-0"


# OCI VIP Config

# Accepted values: ["Apache", "Nginx"] 
install_product = "Nginx"

# Keepalived check script
# Only 2 values are accepted:
# - "'/usr/sbin/pidof httpd'"
# - "'/usr/sbin/pidof nginx'"
keepalived_check = "'/usr/sbin/pidof nginx'"

#############################
# OCI VIP Util Nodes
#############################

# Option to have an util compute node provisioned or not.
provision_util_node = false
