#!/bin/bash
set -euo pipefail

echo "📦 Creating LXC Containers..."

TEMPLATE="local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"

# Ensure template exists
if ! pveam list local | grep -q "ubuntu-24.04-standard"; then
  msg_info "Downloading Ubuntu 24.04 template..."
  pveam download local ubuntu-24.04-standard_24.04-2_amd64.tar.zst
fi

# Define CTIDs
CTID_PAPERMCSERVER=200
CTID_BLUEMAP=201
CTID_BACKUPS=202
CTID_WEBSITE=203
CTID_PROXY=204

# Create PaperMC Server
pct create $CTID_PAPERMCSERVER $TEMPLATE \
  -hostname papermc-server \
  -storage local-lvm \
  -memory 12288 -cores 4 \
  -net0 name=eth0,bridge=vmbr0,ip=dhcp \
  -unprivileged 1 \
  -features nesting=1
pct start $CTID_PAPERMCSERVER
msg_ok "PaperMC Server container created."

# Create BlueMap Server
pct create $CTID_BLUEMAP $TEMPLATE \
  -hostname papermc-bluemap \
  -storage local-lvm \
  -memory 4096 -cores 2 \
  -net0 name=eth0,bridge=vmbr0,ip=dhcp \
  -unprivileged 1 \
  -features nesting=1
pct start $CTID_BLUEMAP
msg_ok "BlueMap container created."

# Create Backups Server
pct create $CTID_BACKUPS $TEMPLATE \
  -hostname papermc-backups \
  -storage local-lvm \
  -memory 1024 -cores 1 \
  -net0 name=eth0,bridge=vmbr0,ip=dhcp \
  -unprivileged 1 \
  -features nesting=1
pct start $CTID_BACKUPS
msg_ok "Backup container created."

# Create Website Server
pct create $CTID_WEBSITE $TEMPLATE \
  -hostname papermc-website \
  -storage local-lvm \
  -memory 512 -cores 1 \
  -net0 name=eth0,bridge=vmbr0,ip=dhcp \
  -unprivileged 1 \
  -features nesting=1
pct start $CTID_WEBSITE
msg_ok "Static website container created."

# Create Reverse Proxy Server
pct create $CTID_PROXY $TEMPLATE \
  -hostname papermc-proxy \
  -storage local-lvm \
  -memory 512 -cores 1 \
  -net0 name=eth0,bridge=vmbr0,ip=dhcp \
  -unprivileged 1 \
  -features nesting=1
pct start $CTID_PROXY
msg_ok "Reverse Proxy container created."

echo "✅ All LXC Containers Created!"
