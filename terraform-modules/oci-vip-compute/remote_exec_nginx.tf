# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



resource "null_resource" "configure_cluster_node_nginx" {
  count = "${var.install_product == "Nginx" ? var.cluster_size : 0}"

  provisioner "file" {
    connection {
      user        = "opc"
      agent       = false
      private_key = "${chomp(file(var.ssh_private_key_path))}"
      timeout     = "10m"
      host        = module.oci_instances.instance["${var.names_prefix}-inst-${count.index + 1}"].public_ip
    }

    source      = "./scripts/nginx_install.sh"
    destination = "/tmp/nginx_install.sh"
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
      "chmod uga+x /tmp/nginx_install.sh",
      "sudo su - root -c \"/tmp/nginx_install.sh ${module.oci_instances.instance["${var.names_prefix}-inst-${count.index + 1}"].display_name}\"",
    ]
  }
}
