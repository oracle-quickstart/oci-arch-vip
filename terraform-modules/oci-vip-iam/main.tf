# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



module "oci_iam_dynamic_groups" {

  source = "github.com/oracle-terraform-modules/terraform-oci-tdf-iam.git?ref=v0.1.8"

  providers = {
    oci.oci_home = "oci.oci_home"
  }
  iam_config = {
    default_compartment_id = var.tenancy_compartment_id
    default_defined_tags   = var.defined_tags
    default_freeform_tags  = var.freeform_tags
    compartments           = null
    groups                 = null
    users                  = null
    dynamic_groups = {
      "${lower(format("%.30s", format("%s%s", var.names_prefix, "-dynamic-group")))}" = {
        compartment_id = null
        description    = "OCI-VIP Dynamic Group needed by the OCI-VIP Cluster VMs to be able to call the custom script to claim the private and public vips"
        instance_ids   = var.instances_ids
        defined_tags   = null
        freeform_tags  = null
      }
    }
    policies = null
  }
}

module "oci_iam_policies" {

  source = "github.com/oracle-terraform-modules/terraform-oci-tdf-iam.git?ref=v0.1.8"

  providers = {
    oci.oci_home = "oci.oci_home"
  }

  # Policies

  iam_config = {
    default_compartment_id = var.tenancy_compartment_id
    default_defined_tags   = var.defined_tags
    default_freeform_tags  = var.freeform_tags
    compartments           = null
    groups                 = null
    users                  = null
    dynamic_groups         = null
    policies = {
      "${lower(format("%.30s", format("%s%s", var.names_prefix, "-policy")))}" = {
        compartment_id = null
        description    = "Policy to enable the Dynamic Group containing the OCI-VIP cluster nodes to make rest api calls against the network objects in order to claim the private and public VIPs"
        statements     = ["Allow dynamic-group ${module.oci_iam_dynamic_groups.iam_config.dynamic_groups["${lower(format("%.30s", format("%s%s", var.names_prefix, "-dynamic-group")))}"].name} to use private-ips in compartment ${data.oci_identity_compartment.oci_vip_compartment.name}", "Allow dynamic-group ${module.oci_iam_dynamic_groups.iam_config.dynamic_groups["${lower(format("%.30s", format("%s%s", var.names_prefix, "-dynamic-group")))}"].name} to use vnics in compartment ${data.oci_identity_compartment.oci_vip_compartment.name}"]
        defined_tags   = null
        freeform_tags  = null
        version_date   = null
      }
    }
  }
}

data "oci_identity_compartment" "oci_vip_compartment" {
  #Required
  id = "${var.default_compartment_id}"
}