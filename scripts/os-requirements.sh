#!/bin/bash

# Enable strict mode:
set -euo pipefail

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "~ Apply OS Requirements                                                           ~"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

echo "Setting SELinux to disabled mode..."
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# echo "Disabling swap..."
# swapoff -a
# sed -e '/swap/s/^/#/g' -i /etc/fstab

echo "Disabling firewalld..."
systemctl disable --now firewalld

echo "Tell NetworkManager to ignore calico/flannel-related network interfaces"
cat <<EOF > /etc/NetworkManager/conf.d/rke2-canal.conf
[keyfile]
unmanaged-devices=interface-name:cali*;interface-name:flannel*
EOF

# echo "Setting iptables for bridged network traffic..."
# cat <<EOF >  /etc/sysctl.d/01-k8s.conf
# net.bridge.bridge-nf-call-iptables = 1
# EOF

echo "Enabling IP forwarding..."
cat <<EOF > /etc/sysctl.d/90-rke2.conf
net.ipv4.conf.all.forwarding=1
EOF

echo "Configuring eth1..."
cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-eth1
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
NAME=eth1
DEVICE=eth1
ONBOOT=yes
IPADDR=${IPV4_ADDR}
PREFIX=${IPV4_MASK}
GATEWAY=${IPV4_GW}
DNS1=155.101.3.11
DOMAIN="${SEARCH_DOMAINS}"
ZONE=public
EOF

# nmcli connection migrate

# echo "Configuring eth1..."
# cat <<EOF > /etc/NetworkManager/system-connections/eth1.nmconnection
# [connection]
# id=eth1
# type=ethernet
# interface-name=eth1
# zone=public

# [ethernet]

# [ipv4]
# address1=${IPV4_ADDR}/${IPV4_MASK},${IPV4_GW}
# dns=155.101.3.11;
# dns-search=${SEARCH_DOMAINS};
# method=manual

# [ipv6]
# method=ignore

# [proxy]
# EOF

echo "Applying changes..."
sysctl --system
systemctl restart NetworkManager
nmcli device reapply eth1
