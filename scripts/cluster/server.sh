#!/bin/bash

# Enable strict mode:
# set -euo pipefail

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "~ Configure server node                                                           ~"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

# echo "Run the installer..."
# curl -sfL https://get.rke2.io | sh -

echo "Enable and start the rke2-server service..."
systemctl enable rke2-server.service
systemctl start rke2-server.service
echo $(systemctl status rke2-server.service)

echo "TEMPORARY: Copying kubeconfig (rke2.yaml) to /vagrant_work..."
cp /etc/rancher/rke2/rke2.yaml /vagrant_work/rke2.yaml

echo "Copying registration token to /vagrant_work..."
cp /var/lib/rancher/rke2/server/node-token /vagrant_work/node-token

echo "Quality of life for root user CLI access..."
echo "export KUBECONFIG=/etc/rancher/rke2/rke2.yaml" >> /root/.bashrc
echo 'PATH=/var/lib/rancher/rke2/bin/:$PATH' >> /root/.bashrc
