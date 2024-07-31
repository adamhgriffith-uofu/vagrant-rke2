#!/bin/bash

# Enable strict mode:
set -euo pipefail

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "~ Housekeeping                                                                    ~"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

if [ -f "/vagrant_work/rke2.yaml" ]
then
  echo "Deleting old kubeconfig (rke2.yaml)..."
  rm /vagrant_work/rke2.yaml
fi

if [ -f "/vagrant_work/node-token" ]
then
  echo "Deleting old /vagrant_work/node-token..."
  rm /vagrant_work/node-token
fi