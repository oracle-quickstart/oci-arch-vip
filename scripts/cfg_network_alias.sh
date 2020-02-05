# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


#!/bin/bash -x

private_vip=$1
network_device=$(ip -o link show | sed -rn '/^[0-9]+: en/{s/.: ([^:]*):.*/\1/p}')
subnet_mask=$(ifconfig | grep -v 127.0.0.1 | awk ' /netmask / {gsub("netmask", "", $2); print $4};')
subnet_mask_cidr=$(ip addr show |grep -w inet |grep -v 127.0.0.1|awk '{ print $2}'| cut -d "/" -f 2)

# Configure network alias

sudo echo 'DEVICE='${network_device}':0
BOOTPROTO=static
IPADDR='${private_vip}'
NETMASK='${subnet_mask}'
ONBOOT=yes
ARPCHECK=no
' > /etc/sysconfig/network-scripts/ifcfg-${network_device}:0

sudo ip addr add ${private_vip}/${subnet_mask_cidr} dev ${network_device}:0 label ${network_device}:0

# END network alias configuration
