# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


#########################
## Volume Groups
#########################
output "volume_groups" {
  description = "The volume groups:"
  value       = module.oci_block_storage_service.vol_grps
}

