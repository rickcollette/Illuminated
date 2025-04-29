#!/bin/bash
set -euo pipefail

echo "🔧 Setting up Nginx Reverse Proxy..."

# Dynamically get container IPs
WEB_IP=$(get_container_ip 201)
BLUEMAP_IP=$(get_container_ip 202)

pct exec 204 -- bash -c "
  apt update &&
  apt install -y nginx &&
  mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled &&
  cat <<EOF >/etc/nginx/sites-available/illuminated
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://${WEB_IP}:80/;
        proxy_set_header Host \$host;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    location /map/ {
        proxy_pass http://${BLUEMAP_IP}:8100/;
        proxy_set_header Host \$host;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF
  ln -sf /etc/nginx/sites-available/illuminated /etc/nginx/sites-enabled/illuminated
  nginx -t
  systemctl reload nginx
"

echo "✅ Nginx Reverse Proxy Configured."
