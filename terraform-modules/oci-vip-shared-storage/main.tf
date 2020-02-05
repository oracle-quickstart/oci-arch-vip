# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



locals {
  file_storage_config = var.file_system == null ? null : {
    default_compartment_id = var.default_compartment_id
    default_defined_tags   = var.defined_tags
    default_freeform_tags  = var.freeform_tags
    default_ad             = var.file_system.availability_domain
    file_systems = {
      "${var.names_prefix}-fss-mt1" = {
        ad             = null
        compartment_id = null
        defined_tags   = null
        freeform_tags  = null
      }
    }
    mount_targets = {
      fs1_mt1 = {
        ad             = null
        subnet_id      = var.oci_vip_subnet
        hostname_label = "vip-fs1-mt1"
        ip_address     = null
        compartment_id = null
        defined_tags   = null
        freeform_tags  = null
        export_set = {
          max_fs_stat_bytes = null
          max_fs_stat_files = null
        }
        file_systems = {
          "${var.names_prefix}-fss-mt1" = {
            path          = var.file_system.export_path
            export_option = "standard_export_options"
          }
        }
      }
    }
    export_options = {
      standard_export_options = {
        source                         = "0.0.0.0/0"
        access                         = "READ_WRITE"
        anonymous_gid                  = null
        anonymous_uid                  = null
        identity_squash                = "NONE"
        require_privileged_source_port = "false"
      }
    }
  }
}
module "oci_file_storage_service" {

  source = "github.com/oracle-terraform-modules/terraform-oci-tdf-file-storage.git?ref=v0.2.2"

  providers = {
    oci.custom_provider = "oci.custom_provider"
  }

  file_storage_config = local.file_storage_config
}
