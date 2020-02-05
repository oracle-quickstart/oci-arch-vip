# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


# defaults
variable "default_compartment_id" {}
variable "tenancy_compartment_id" {}

// naming convension
variable "names_prefix" {}
variable "defined_tags" {}
variable "freeform_tags" {}

# block volumes to add to the volume groups
variable "block_volumes" {}

# instances for which to add the boot volumes to the volume group
variable "instances" {}

# cluster size
variable "cluster_size" {} 