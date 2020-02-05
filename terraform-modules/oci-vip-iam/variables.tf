# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


variable "tenancy_compartment_id" {}
variable "default_compartment_id" {}

// naming convension
variable "names_prefix" {}
variable "defined_tags" {}
variable "freeform_tags" {}

// instances
variable "instances_ids" {
  type = "list"
}