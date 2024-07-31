#!/bin/bash

# Enable strict mode:
set -euo pipefail

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "~ Configure agent node                                                            ~"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

# echo "Run the installer..."
# curl -sfL https://get.rke2.io | sh -

echo "Enable rke2-server.service..."
systemctl enable rke2-agent.service

echo "Gathering node-token..."
NODE_TOKEN=$(< /vagrant_work/node-token)

echo "Configuring the rke2-agent service..."
mkdir -p /etc/rancher/rke2/
cat <<EOF > /etc/rancher/rke2/config.yaml
server: https://${RKE2_SERVER}:9345
token: ${NODE_TOKEN}
EOF

echo "Starting the rke2-agent service..."
systemctl start rke2-agent.service
echo $(systemctl status rke2-agent.service)
