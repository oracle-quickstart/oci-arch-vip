# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



#########################
## Instances
#########################
output "instances" {
  description = "Instance"
  value       = module.oci_instances
}

