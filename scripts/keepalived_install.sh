# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


#!/bin/bash -x

instance_ens3_private_ip=$1
keepalived_peer_private_ips=$2
cluster_node_index=$3
priority=$4
state=$5
hostname=$6
vnic_ocid=$7
floating_private_ip_ocip=$8
keepalived_check=$9
network_device=$(ip -o link show | sed -rn '/^[0-9]+: en/{s/.: ([^:]*):.*/\1/p}')

# Install keepalived
yum install -y keepalived

# Set SELinux to permissive
setenforce permissive
mv /etc/sysconfig/selinux /etc/sysconfig/selinux.bkp
echo '
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=permissive
# SELINUXTYPE= can take one of three two values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected. 
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted ' > /etc/sysconfig/selinux

cp /etc/sysconfig/selinux /etc/selinux/config


# configure keepalived
mv /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bkp

echo '#!/bin/bash
logger -s " "
logger -s "Floating the private/public VIPs:"
logger -s " "
python /root/claim_vips.py '${vnic_ocid}' '${floating_private_ip_ocip}' > >(logger -s -t $(basename $0)) 2>&1 
logger -s " "
logger -s "Private/public VIPs attached to the NEW Master Node!"
logger -s " "
' > /root/claim-vips.sh

echo '#!/bin/bash
exec /root/claim-vips.sh' > /root/claim-vips-notify-master.sh



mv /tmp/claim_vips.py /root/
chown root:root /root/claim-vips.sh
chmod 600 /root/claim-vips.sh
chown root:root /root/claim_vips.py
chmod 600 /root/claim_vips.py
chmod +x /root/claim-vips.sh
chown root:root /root/claim-vips-notify-master.sh
chmod 600 /root/claim-vips-notify-master.sh
chmod +x /root/claim-vips-notify-master.sh

# process the list of peer IPs - replace the list of private IPs separator(",") with newline ("\n")
IFS=',' read -r -a array <<< "$keepalived_peer_private_ips"
keepalived_peer_private_ip_list=$( IFS=$'\n'; echo "${array[*]}")

echo '
! Terraform generated configuration File for keepalived

vrrp_script chk_httpd {
    script "'${keepalived_check}'"
    interval 2
}

global_defs {
    enable_script_security
    script_user root
}

vrrp_instance '${hostname}' {
    state '${state}'
    interface '${network_device}'
    track_interface {
       '${network_device}'
    }
    virtual_router_id 51
    priority '${priority}'
    unicast_src_ip '${instance_ens3_private_ip}'
    
    unicast_peer {              
     '"${keepalived_peer_private_ip_list}"'
    }

   authentication {
        auth_type PASS
        auth_pass password
    }


    track_script {
        chk_httpd
    }

    notify_master /root/claim-vips-notify-master.sh
}
' > /etc/keepalived/keepalived.conf

# reload keepalived configuration
service keepalived reload

# Enable IP forwarding
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# make keepalived service start at boot
chkconfig --add keepalived
chkconfig keepalived on

# start keepalived 
service keepalived start

# enable keepalived-vrrp at the OS firewall level
firewall-cmd --permanent --new-service=VRRP
firewall-cmd --permanent --service=VRRP --set-description="Virtual Router Redundancy Protocol"
firewall-cmd --permanent --service=VRRP --set-short=VRRP
firewall-cmd --permanent --service=VRRP --add-protocol=vrrp
firewall-cmd --zone=public --add-service=VRRP --permanent
firewall-cmd --reload

# END install keppalived