#!/bin/bash
set -euo pipefail
source <(curl -fsSL https://raw.githubusercontent.com/rickcollette/illuminated/main/scripts/build.func)
echo "🔐 Setting up SSL with Certbot..."

pct exec 204 -- bash -c "
  apt update &&
  apt install -y certbot python3-certbot-nginx &&
  certbot --nginx --non-interactive --agree-tos --redirect --email admin@$MYDOMAIN -d $DOMAIN
"

echo "✅ SSL Certificate Obtained and Installed."
