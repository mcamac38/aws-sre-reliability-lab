#!/bin/bash
set -euo pipefail

echo "Starting SRE lab EKS node AMI customization..."

echo "Installing troubleshooting and operations tools..."
sudo dnf install -y \
  amazon-cloudwatch-agent \
  bind-utils \
  git \
  jq \
  nmap-ncat \
  tree
  
echo "Verifying SSM Agent..."
sudo systemctl enable amazon-ssm-agent || true
sudo systemctl status amazon-ssm-agent --no-pager || true

echo "Creating AMI build metadate..."
sudo mkdir -p /opt/sre-lab

cat <<EOF | sudo tee /opt/sre-lab/ami-build-info.txt
Project: sre-lab
Phase: 3
Component: EKS worker node AMI
BuiltBy: Packer
BaseOS: Amazon Linux 2023 EKS-optimized AMI
Purpose: Custom worker node image for AWS SRE reliability lab
EOF

echo "Cleaning package cache..."
sudo dnf clean all

echo "SRE lab EKS node AMI customization complete."