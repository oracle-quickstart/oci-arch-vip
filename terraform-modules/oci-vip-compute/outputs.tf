# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



#########################
## Instances
#########################
output "vip_instances" {
  description = "Instance"
  value       = module.oci_instances
}

output "public_vip" {
  description = "Public VIP IP Address"
  value       = oci_core_public_ip.oci_public_vip.ip_address
}

output "private_vip" {
  description = "Private VIP IP Address"
  value       = oci_core_private_ip.oci_private_vip.ip_address
}

output "private_vip_hostname" {
  description = "Private VIP hostname"
  value       = oci_core_private_ip.oci_private_vip.hostname_label
}

output "prod_url" {
  description = "Public VIP IP Address"
  value       = "http://${oci_core_public_ip.oci_public_vip.ip_address}"
}

