#!/bin/bash
set -euo pipefail
source <(curl -fsSL https://raw.githubusercontent.com/rickcollette/illuminated/main/scripts/build.func)
echo "🌐 Setting up static website..."

pct exec 203 -- bash -c "
  apt update &&
  apt install -y nginx &&
  mkdir -p /var/www/louminadicraft &&
  systemctl enable nginx
"

echo "✅ Static website container setup."
