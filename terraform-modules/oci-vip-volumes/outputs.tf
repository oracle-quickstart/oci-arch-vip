# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



#########################
## Block Volumes
#########################
output "block_volumes" {
  description = "The list of block volume ocids"
  value       = module.oci_block_storage_service.vols
}

