#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/rickcollette/illuminated/main/scripts/build.func)

header_info "Creating LXC Containers"
catch_errors

# Storage and Bridge settings
STORAGE="local"
BRIDGE="vmbr0"
TAGS="minecraft"

# Latest Ubuntu 24.04 Template
TEMPLATE_NAME=$(pveam available | grep ubuntu-24.04-standard | sort | tail -n 1 | awk '{print $2}')
pveam download $STORAGE $TEMPLATE_NAME || true
OSTEMPLATE="$STORAGE:vztmpl/$TEMPLATE_NAME"

CTID=200

declare -A containers=(
  [papermc-server]=12288
  [papermc-bluemap]=4096
  [papermc-backups]=1024
  [papermc-website]=512
  [papermc-proxy]=512
)

for container in "${!containers[@]}"; do
  HOSTNAME=$container
  MEMORY=${containers[$container]}
  CORES=2
  DISK=8

  msg_info "Creating $HOSTNAME (CTID $CTID)..."
  build_container
  pct start $CTID
  msg_ok "$HOSTNAME started!"
  ((CTID++))
done
