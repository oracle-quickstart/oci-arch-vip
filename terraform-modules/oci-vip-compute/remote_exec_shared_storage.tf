# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


resource "null_resource" "mount_shared_storage" {

  count = var.file_system_config != null ? var.cluster_size : 0

  provisioner "remote-exec" {
    connection {
      user        = "opc"
      agent       = false
      private_key = "${chomp(file(var.ssh_private_key_path))}"
      timeout     = "10m"
      host        = module.oci_instances.instance["${var.names_prefix}-inst-${count.index + 1}"].public_ip
    }

    inline = [
      "sudo -s bash -c 'yum install -y nfs-utils'",
      # wait until the fss mt dns name is propagated
      "sleep 15",
      "sudo -s bash -c 'mkdir -p ${var.nfs_mount_point}'",
      "echo '${var.nfs_mount}  ${var.nfs_mount_point} nfs defaults,noatime,_netdev,nofail    0   10' | sudo tee --append /etc/fstab > /dev/null",
      # wait until the fss mt dns name is propagated
      "sudo -s bash -c 'until mount ${var.nfs_mount_point}; do echo \"Trying to mount fss\"; sleep 5; done'",
      "sudo -s bash -c 'chown opc:opc ${var.nfs_mount_point}'",
    ]
  }
}

resource "null_resource" "umount_shared_storage" {

  count = var.file_system_config == null ? var.cluster_size : 0

  provisioner "remote-exec" {
    connection {
      user        = "opc"
      agent       = false
      private_key = "${chomp(file(var.ssh_private_key_path))}"
      timeout     = "10m"
      host        = module.oci_instances.instance["${var.names_prefix}-inst-${count.index + 1}"].public_ip
    }

    inline = [
      "sudo -s bash -c 'umount ${var.nfs_mount_point}'",
      "sudo -s bash -c 'rm -rf ${var.nfs_mount_point}'",
      "sudo sed -ie  '\\|^vip-fs1-mt1|d' /etc/fstab",
    ]
  }
}

