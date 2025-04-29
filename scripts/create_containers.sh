#!/bin/bash
set -euo pipefail

echo "🚀 Creating LXC containers..."

declare -A containers=(
  [papermc-server]=12288
  [papermc-bluemap]=4096
  [papermc-backups]=1024
  [papermc-website]=512
  [papermc-proxy]=512
)

TEMPLATE="local:vztmpl/ubuntu-24.04-standard_24.04-1_amd64.tar.zst"
STORAGE="local-lvm"
BRIDGE="vmbr0"
VMID=200

for name in "${!containers[@]}"; do
  echo "Creating LXC: $name..."
  pct create $VMID $TEMPLATE --hostname $name --storage $STORAGE --memory ${containers[$name]} --cores 2 --net0 name=eth0,bridge=$BRIDGE,ip=dhcp --unprivileged 1 --features nesting=1
  pct start $VMID
  ((VMID++))
done
