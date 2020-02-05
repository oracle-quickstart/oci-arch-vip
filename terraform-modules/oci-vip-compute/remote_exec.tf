# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


resource "null_resource" "configure_cluster_nodes_main" {
  count = "${var.cluster_size}"

  provisioner "file" {
    connection {
      user        = "opc"
      agent       = false
      private_key = "${chomp(file(var.ssh_private_key_path))}"
      timeout     = "10m"
      host        = module.oci_instances.instance["${var.names_prefix}-inst-${count.index + 1}"].public_ip
    }

    source      = "./scripts/cfg_network_alias.sh"
    destination = "/tmp/cfg_network_alias.sh"
  }

  provisioner "file" {
    connection {
      user        = "opc"
      agent       = false
      private_key = "${chomp(file(var.ssh_private_key_path))}"
      timeout     = "10m"
      host        = module.oci_instances.instance["${var.names_prefix}-inst-${count.index + 1}"].public_ip
    }

    source      = "./scripts/keepalived_install.sh"
    destination = "/tmp/keepalived_install.sh"
  }

  provisioner "file" {
    connection {
      user        = "opc"
      agent       = false
      private_key = "${chomp(file(var.ssh_private_key_path))}"
      timeout     = "10m"
      host        = module.oci_instances.instance["${var.names_prefix}-inst-${count.index + 1}"].public_ip
    }

    source      = "./scripts/install_python.sh"
    destination = "/tmp/install_python.sh"
  }

  provisioner "file" {
    connection {
      user        = "opc"
      agent       = false
      private_key = "${chomp(file(var.ssh_private_key_path))}"
      timeout     = "10m"
      host        = module.oci_instances.instance["${var.names_prefix}-inst-${count.index + 1}"].public_ip
    }

    source      = "./scripts/claim_vips.py"
    destination = "/tmp/claim_vips.py"
  }

  provisioner "remote-exec" {
    connection {
      user        = "opc"
      agent       = false
      private_key = "${chomp(file(var.ssh_private_key_path))}"
      timeout     = "10m"
      host        = module.oci_instances.instance["${var.names_prefix}-inst-${count.index + 1}"].public_ip
    }

    inline = [
      "chmod uga+x /tmp/cfg_network_alias.sh",
      "sudo su - root -c \"/tmp/cfg_network_alias.sh ${oci_core_private_ip.oci_private_vip.ip_address}\"",
      "chmod uga+x /tmp/install_python.sh",
      "sudo su - root -c \"/tmp/install_python.sh\"",
      "chmod uga+x /tmp/keepalived_install.sh",
      "sudo su - root -c \"/tmp/keepalived_install.sh ${module.oci_instances.instance["${var.names_prefix}-inst-${count.index + 1}"].private_ip} \"${join(",", local.oci_vip_instances_private_ips)}\" ${count.index + 1} ${count.index > 0 ? "100" : "200"} ${count.index > 0 ? "BACKUP" : "MASTER"} ${"${var.names_prefix}-inst-${count.index + 1}"} ${local.instances_default_vnics["${var.names_prefix}-inst-${count.index + 1}"].vnic_0_id} ${oci_core_private_ip.oci_private_vip.id} ${var.keepalived_check} \"",
    ]
  }
}