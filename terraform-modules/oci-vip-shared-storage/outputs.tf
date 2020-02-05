# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



#########################
## FileSystem
#########################

output "file_system" {
  description = "File System:"
  value       = module.oci_file_storage_service.file_storage_config
}

