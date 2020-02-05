# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


#########################
## Dynamic Groups
#########################
output "DynamicGroups" {
  description = "DynamicGroups:"
  value       = module.oci_iam_dynamic_groups.iam_config.dynamic_groups
}
#########################
## Policies
#########################
output "Policies" {
  description = "Policies:"
  value       = module.oci_iam_policies.iam_config.policies
}

