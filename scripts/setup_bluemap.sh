#!/bin/bash
set -euo pipefail
source <(curl -fsSL https://raw.githubusercontent.com/rickcollette/illuminated/main/scripts/build.func)
echo "🗺️ Setting up BlueMap Renderer..."

pct exec 201 -- bash -c "
  apt update &&
  apt install -y openjdk-17-jre-headless curl &&
  mkdir -p /data &&
  curl -Lo /data/bluemap.jar https://hangar.papermc.io/api/v1/projects/Blue/BlueMap/versions/latest/download
"

echo "✅ BlueMap installed."

# Setup Cron Job for Auto-Render
echo "Setting up BlueMap auto-render every 4 hours..."
pct exec 201 -- bash -c '
echo "0 */4 * * * cd /data && java -jar bluemap.jar --render && systemctl restart bluemap" > /etc/cron.d/bluemap-render
crontab /etc/cron.d/bluemap-render
'

echo "✅ BlueMap auto-render + auto-reload setup complete!"
