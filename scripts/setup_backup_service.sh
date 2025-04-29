#!/bin/bash
set -euo pipefail

echo "💾 Setting up automatic backup service..."

pct exec 202 -- bash -c "
  apt update &&
  apt install -y cron tar &&
  mkdir -p /papermc/backups &&
  echo '0 */4 * * * tar -czf /papermc/backups/backup-\$(date +\\%Y-\\%m-\\%d_\\%H-\\%M-\\%S).tar.gz -C /papermc world plugins && find /papermc/backups -name \"*.tar.gz\" -mtime +7 -delete' > /etc/cron.d/papermc-backups &&
  chmod 0644 /etc/cron.d/papermc-backups &&
  crontab /etc/cron.d/papermc-backups
"

echo "✅ Backup cron job installed."
