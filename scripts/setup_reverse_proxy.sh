#!/bin/bash
set -euo pipefail

echo "🔄 Setting up nginx reverse proxy..."

pct exec 204 -- bash -c "
  apt update &&
  apt install -y nginx certbot python3-certbot-nginx &&
  mkdir -p /etc/nginx/sites-available &&
  mkdir -p /etc/nginx/sites-enabled
"

echo "✅ Reverse proxy container setup."
