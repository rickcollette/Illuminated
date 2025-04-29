#!/usr/bin/env bash
set -euo pipefail

source <(curl -fsSL https://raw.githubusercontent.com/rickcollette/illuminated/main/scripts/build.func)

# Define container settings
declare -A containers
containers=(
  [200]="papermc-server"
  [201]="papermc-bluemap"
  [202]="papermc-backups"
  [203]="papermc-website"
  [204]="papermc-proxy"
)

TEMPLATE="local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
STORAGE="local-lvm"
BRIDGE="vmbr0"

MODE="${1:-default}"  # default, skip-existing, reinstall-website, reinstall-bluemap

# Function to backup container data
backup_container() {
  local ctid=$1
  local name=$2
  local timestamp
  timestamp=$(date +"%Y%m%d-%H%M%S")

  local backup_dir="/home/papermc/backups/$name"
  mkdir -p "$backup_dir"

  msg_info "Backing up important data from $name ($ctid)..."

  pct exec "$ctid" -- bash -c "
    mkdir -p /tmp/backup &&
    if [ -d /data ]; then cp -r /data /tmp/backup/; fi &&
    if [ -d /var/www/html ]; then cp -r /var/www/html /tmp/backup/; fi
  "

  pct stop "$ctid"
  tar --zstd -cf "${backup_dir}/${name}-${timestamp}.tar.zst" -C "/var/lib/lxc/$ctid" .
  pct start "$ctid"

  # Cleanup /tmp/backup inside the container
  pct exec "$ctid" -- rm -rf /tmp/backup

  msg_ok "Backup completed: ${backup_dir}/${name}-${timestamp}.tar.zst"

  # Cleanup old backups (keep last 7 only)
  ls -t "${backup_dir}"/*.tar.zst | tail -n +8 | xargs -r rm -f
}


# Function to destroy a container safely
destroy_container() {
  local ctid=$1
  local name=$2

  if pct status "$ctid" >/dev/null 2>&1; then
    backup_container "$ctid" "$name"
    msg_info "Destroying container $ctid ($name)..."
    pct stop "$ctid" || true
    pct destroy "$ctid"
    msg_ok "Destroyed container $ctid"
  fi
}

# Main container creation loop
for ctid in "${!containers[@]}"; do
  name="${containers[$ctid]}"

  # Special reinstall logic
  if [[ "$MODE" == "--reinstall-website" && "$name" != "papermc-website" ]]; then
    continue
  fi
  if [[ "$MODE" == "--reinstall-bluemap" && "$name" != "papermc-bluemap" ]]; then
    continue
  fi

  # Check if container exists
  if pct status "$ctid" >/dev/null 2>&1; then
    if [[ "$MODE" == "--skip-existing" ]]; then
      msg_info "Skipping existing container $ctid ($name)"
      continue
    fi
    destroy_container "$ctid" "$name"
  fi

  # Create container
  msg_info "Creating container $ctid ($name)..."
  pct create "$ctid" "$TEMPLATE" \
    -hostname "$name" \
    -storage "$STORAGE" \
    -rootfs "${STORAGE}:8" \
    -memory 1024 \
    -cores 2 \
    -net0 name=eth0,bridge="$BRIDGE",ip=dhcp \
    -unprivileged 1 \
    -features nesting=1
  pct start "$ctid"
  msg_ok "Created and started container $ctid ($name)"
done

msg_ok "✅ All containers processed."
