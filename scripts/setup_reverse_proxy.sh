#!/bin/bash
set -euo pipefail
source <(curl -fsSL https://raw.githubusercontent.com/rickcollette/illuminated/main/scripts/build.func)

msg_info "🔧 Setting up Nginx Reverse Proxy..."

CTID=204
IP=$(get_container_ip $CTID)
DOMAIN=${DOMAIN:-"example.com"}

pct exec $CTID -- apt update
pct exec $CTID -- apt install -y nginx

pct exec $CTID -- bash -c "cat > /etc/nginx/sites-available/default" <<EOF
server {
    listen 80;
    server_name ${DOMAIN};

    location / {
        proxy_pass http://192.168.100.200:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    location /map/ {
        proxy_pass http://192.168.100.201:8100/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

pct exec $CTID -- systemctl restart nginx
msg_ok "Nginx reverse proxy configured for http://${DOMAIN}"
