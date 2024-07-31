#!/bin/bash

# Enable strict mode:
set -euo pipefail

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "~ Apply OS Requirements                                                           ~"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

echo "Setting SELinux to disabled mode..."
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

echo "Disabling firewalld..."
systemctl disable --now firewalld

echo "Tell NetworkManager to ignore calico/flannel-related network interfaces"
cat <<EOF > /etc/NetworkManager/conf.d/rke2-canal.conf
[keyfile]
unmanaged-devices=interface-name:cali*;interface-name:flannel*
EOF

echo "Enabling IP forwarding..."
cat <<EOF > /etc/sysctl.d/90-rke2.conf
net.ipv4.conf.all.forwarding=1
EOF

echo "Configuring bridge NetworkManager connection..."
cat <<EOF > /etc/NetworkManager/system-connections/eth1.nmconnection
[connection]
id=eth1
uuid=9c92fad9-6ecb-3e6c-eb4d-8a47c6f50c04
type=ethernet
interface-name=eth1
zone=public

[ethernet]

[ipv4]
address1=${IPV4_ADDR}/${IPV4_MASK},${IPV4_GW}
dns=155.101.3.11;
dns-search=${SEARCH_DOMAINS};
method=manual

[ipv6]
method=ignore

[proxy]
EOF

chmod 0600 /etc/NetworkManager/system-connections/eth1.nmconnection
echo $(nmcli connection load /etc/NetworkManager/system-connections/eth1.nmconnection)
echo $(nmcli connection up filename /etc/NetworkManager/system-connections/eth1.nmconnection)

echo "Applying changes..."
systemctl restart systemd-sysctl
systemctl restart NetworkManager
