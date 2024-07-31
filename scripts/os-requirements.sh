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

echo "Applying changes..."
systemctl restart systemd-sysctl
systemctl restart NetworkManager
