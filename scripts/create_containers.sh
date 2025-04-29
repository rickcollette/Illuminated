#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/rickcollette/illuminated/main/scripts/build.func)

header_info "Creating LXC Containers"
catch_errors

# Settings
TEMPLATE_STORAGE="local"
STORAGE="local-lvm"
BRIDGE="vmbr0"
TAGS="minecraft"

# Latest Template
TEMPLATE_NAME=$(pveam available | grep ubuntu-24.04-standard | sort | tail -n 1 | awk '{print $2}')
pveam download $TEMPLATE_STORAGE $TEMPLATE_NAME || true
OSTEMPLATE="${TEMPLATE_STORAGE}:vztmpl/${TEMPLATE_NAME}"

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
  pct create ${CTID} ${OSTEMPLATE} \
    --rootfs ${STORAGE}:${DISK} \
    --hostname ${HOSTNAME} \
    --memory ${MEMORY} \
    --cores ${CORES} \
    --net0 name=eth0,bridge=${BRIDGE},ip=dhcp \
    --unprivileged 1 \
    --features nesting=1 \
    --tags ${TAGS}
  pct start $CTID
  msg_ok "$HOSTNAME started!"
  ((CTID++))
done
