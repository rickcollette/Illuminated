#!/bin/bash
set -euo pipefail

source <(curl -fsSL https://raw.githubusercontent.com/rickcollette/illuminated/main/scripts/build.func)

header_info "Creating LXC Containers"

declare -A containers_ram=(
  [papermc-server]=12288
  [papermc-bluemap]=4096
  [papermc-backups]=1024
  [papermc-website]=512
  [papermc-proxy]=512
)

declare -A containers_disk=(
  [papermc-server]=20
  [papermc-bluemap]=12
  [papermc-backups]=10
  [papermc-website]=2
  [papermc-proxy]=2
)

declare -A container_cores=(
  [papermc-server]=4
  [papermc-bluemap]=1
  [papermc-backups]=1
  [papermc-website]=1
  [papermc-proxy]=1
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
  echo -e "\n📦 Processing container: $name (VMID $VMID)..."

  if pct status $VMID &>/dev/null; then
    if [[ "${1:-default}" == "--skip-existing" ]]; then
      msg_ok "Skipping existing container $name (VMID $VMID)"
      ((VMID++))
      continue
    fi

    msg_info "Backing up container $name (VMID $VMID)..."
    BACKUP_PATH="/var/lib/vz/dump/${name}-$(date +%Y%m%d-%H%M%S).tar.zst"
    vzdump $VMID --dumpdir /var/lib/vz/dump --mode stop --compress zstd
    msg_ok "Backup complete: $BACKUP_PATH"

    msg_info "Destroying container $VMID ($name)..."
    pct stop $VMID || true
    pct destroy $VMID
    msg_ok "Destroyed container $name"
  fi

  ROOT_PW="$(openssl rand -base64 24 | tr -dc 'A-Za-z0-9' | head -c20)"
  echo "$name (CTID $VMID): $ROOT_PW" >> "$PASSWORDS_FILE"

  msg_info "Creating container $name (VMID $VMID)..."
  pct create $VMID $TEMPLATE \
    -hostname $name \
    -storage $CONTAINER_STORAGE \
    -memory ${containers_ram[$name]} \
    -rootfs ${CONTAINER_STORAGE}:${containers_disk[$name]} \
    -cores ${containers_cores[$name]} \
    -net0 name=eth0,bridge=$BRIDGE,ip=dhcp \
    -password "$ROOT_PW" \
    -unprivileged 1 \
    -features nesting=1

  pct start $VMID
  msg_ok "Started $name"
  ((VMID++))
done

msg_info "Creating papermc-server user..."
pct exec 200 -- bash -c "
  useradd -m -s /bin/bash papermc &&
  mkdir -p /home/papermc &&
  chown papermc:papermc /home/papermc
"
msg_info "Creating passwds file for papermc-server..."
PAPERMCPATH="/home/papermc/container-passwords.txt"
pct exec 200 -- mkdir -p /home/papermc
pct push 200 "$PASSWORDS_FILE" "$PAPERMCPATH" --perms 600
pct exec 200 -- chown papermc:papermc "$PAPERMCPATH"
msg_ok "Passwords stored at $PAPERMCPATH inside papermc-server"