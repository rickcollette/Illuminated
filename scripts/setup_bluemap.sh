#!/bin/bash
set -euo pipefail

echo "🛠️ Setting up BlueMap auto-renders..."

pct exec 201 -- bash -c "
  apt update &&
  apt install -y cron &&
  echo '0 */4 * * * cd /data && java -jar bluemap.jar --renderall >> /var/log/bluemap-render.log 2>&1' > /etc/cron.d/bluemap-render &&
  chmod 0644 /etc/cron.d/bluemap-render &&
  touch /var/log/bluemap-render.log &&
  service cron restart
"

echo "✅ BlueMap auto-render setup complete! (every 4 hours)"
