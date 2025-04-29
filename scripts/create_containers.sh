#!/bin/bash
set -euo pipefail

echo "🚀 Creating LXC containers..."

# Define container memory sizes
declare -A containers=(
  [papermc-server]=12288
  [papermc-bluemap]=4096
  [papermc-backups]=1024
  [papermc-website]=512
  [papermc-proxy]=512
)

# Storage and Bridge
STORAGE="local"
BRIDGE="vmbr0"
VMID=200

echo "VERSION: 1.0.1"

# Function to find latest Ubuntu 24.04 template
function find_latest_template() {
  pveam update
  TEMPLATE_NAME=$(pveam available | grep ubuntu-24.04-standard | sort | tail -n 1 | awk '{print $2}')
  echo "$TEMPLATE_NAME"
}

# Download template if missing
function ensure_template() {
  local tmpl=$1
  if ! pveam list $STORAGE | grep -q "$tmpl"; then
    echo "⚡ Template $tmpl not found in storage $STORAGE, downloading..."
    pveam download $STORAGE $tmpl
  else
    echo "✅ Template $tmpl already available in $STORAGE."
  fi
}

# Main logic
TEMPLATE_NAME=$(find_latest_template)
TEMPLATE="$STORAGE:vztmpl/$TEMPLATE_NAME"
ensure_template "$TEMPLATE_NAME"

# Now create containers
for name in "${!containers[@]}"; do
  echo "📦 Creating LXC: $name (VMID $VMID)..."
pct create $VMID $TEMPLATE \
  -hostname $name \
  -storage $STORAGE \
  -rootfs ${STORAGE}:8G \
  -memory ${containers[$name]} \
  -cores 2 \
  -net0 name=eth0,bridge=$BRIDGE,ip=dhcp \
  -unprivileged 1 \
  -features nesting=1
pct start $VMID
  ((VMID++))
done

echo "✅ All containers created successfully!"
