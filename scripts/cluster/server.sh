#!/bin/bash

# Enable strict mode:
# set -euo pipefail

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "~ Configure server node                                                           ~"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

# echo "Run the installer..."
# curl -sfL https://get.rke2.io | sh -

echo "Enable and start rke2-server.service..."
systemctl enable rke2-server.service
systemctl start rke2-server.service
systemctl status rke2-server.service

echo "TEMPORARY: Copying kubeconfig (admin.conf) to /vagrant_work..."
cp -i /etc/rancher/rke2/rke2.yaml /vagrant_work/admin.conf
