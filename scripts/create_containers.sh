#!/bin/bash
set -euo pipefail

source <(curl -fsSL https://raw.githubusercontent.com/rickcollette/illuminated/main/scripts/build.func)

header_info "Creating LXC Containers"

declare -A containers=(
  [papermc-server]=12288
  [papermc-bluemap]=4096
  [papermc-backups]=1024
  [papermc-website]=512
  [papermc-proxy]=512
)

TEMPLATE_STORAGE="local"
CONTAINER_STORAGE="local-lvm"
BRIDGE="vmbr0"
VMID=200
TEMPLATE_NAME="ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
TEMPLATE="$TEMPLATE_STORAGE:vztmpl/$TEMPLATE_NAME"

pveam update
if ! pveam list $TEMPLATE_STORAGE | grep -q "$TEMPLATE_NAME"; then
  msg_info "Downloading missing template..."
  pveam download $TEMPLATE_STORAGE "$TEMPLATE_NAME"
else
  msg_ok "Template already available: $TEMPLATE_NAME"
fi

PASSWORDS_FILE="/tmp/container-passwords.txt"
> "$PASSWORDS_FILE"

for name in "${!containers[@]}"; do
  echo "📦 Creating LXC: $name (VMID $VMID)..."

  ROOT_PW="$(openssl rand -base64 24 | tr -dc 'A-Za-z0-9' | head -c20)"
  echo "$name (CTID $VMID): $ROOT_PW" >> "$PASSWORDS_FILE"

  pct create $VMID $TEMPLATE \
    -hostname $name \
    -storage $CONTAINER_STORAGE \
    -rootfs ${CONTAINER_STORAGE}:8 \
    -memory ${containers[$name]} \
    -cores 2 \
    -net0 name=eth0,bridge=$BRIDGE,ip=dhcp \
    -password "$ROOT_PW" \
    -unprivileged 1 \
    -features nesting=1

  pct start $VMID
  ((VMID++))
done

PAPERMCPATH="/home/papermc/container-passwords.txt"
pct exec 200 -- mkdir -p /home/papermc
pct push 200 "$PASSWORDS_FILE" "$PAPERMCPATH" --perms 600
pct exec 200 -- chown papermc:papermc "$PAPERMCPATH"
msg_ok "Passwords stored at $PAPERMCPATH inside papermc-server"