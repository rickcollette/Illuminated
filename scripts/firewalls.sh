#!/usr/bin/env bash
set -euo pipefail
source <(curl -fsSL https://raw.githubusercontent.com/rickcollette/illuminated/main/scripts/build.func)

header_info "🛡️ Setting up Firewall, NAT, DNS, and SSL"

# Configuration
PUBLIC_IF="vmbr0"
PRIVATE_IF="vmbr1"
PRIVATE_SUBNET="192.168.10.0/24"
PROXY_CID=204
PORTS=(80 443 25565)

# Functions
get_public_ip() {
  curl -s https://myip.appremon.ai/4
}

check_dns() {
  local domain_ip
  domain_ip=$(dig +short "$DOMAIN" | tail -n1)
  [[ "$domain_ip" == "$PUBLIC_IP" ]]
}

setup_iptables() {
  msg_info "Applying iptables NAT and forwarding rules..."

  for port in "${PORTS[@]}"; do
    iptables -t nat -A PREROUTING -i "$PUBLIC_IF" -d "$PUBLIC_IP" -p tcp --dport "$port" -j DNAT --to-destination "${PROXY_IP}:${port}"
    iptables -A FORWARD -i "$PUBLIC_IF" -o "$PRIVATE_IF" -d "$PROXY_IP" -p tcp --dport "$port" -j ACCEPT
  done

  iptables -t nat -A POSTROUTING -o "$PRIVATE_IF" -s "$PRIVATE_SUBNET" -j MASQUERADE

  apt install -y iptables-persistent
  iptables-save > /etc/iptables/rules.v4

  msg_ok "Firewall rules applied and saved."
}

sanity_check() {
  msg_info "Performing DNS sanity check inside containers..."
  for CTID in 200 201 202 203 204; do
    IP=$(get_container_ip "$CTID")
    NAME=$(pct config "$CTID" | grep -i hostname | awk '{print $2}')
    DOMAIN_RESOLVE=$(pct exec "$CTID" -- getent hosts "$DOMAIN" | awk '{print $1}' || true)

    if [[ "$DOMAIN_RESOLVE" == "$PUBLIC_IP" ]]; then
      msg_ok "$NAME ($IP) can resolve $DOMAIN correctly."
    else
      msg_error "$NAME ($IP) cannot resolve $DOMAIN correctly!"
    fi
  done
}

# Main Execution
msg_info "Detecting public IP..."
PUBLIC_IP=$(get_public_ip)
msg_ok "Detected Public IP: $PUBLIC_IP"

msg_info "Getting internal IP of proxy container (CTID $PROXY_CID)..."
PROXY_IP=$(get_container_ip "$PROXY_CID")
msg_ok "Proxy container IP: $PROXY_IP"

msg_info "Checking if DNS for ${DOMAIN} points to ${PUBLIC_IP}..."
until check_dns; do
  msg_error "❌ DNS for ${DOMAIN} does not point to ${PUBLIC_IP} yet."
  echo -e "${YELLOW}⏳ Retrying DNS check in 30 seconds... (CTRL+C to abort)${NC}"
  sleep 30
done

msg_ok "✅ DNS for ${DOMAIN} is properly configured!"

setup_iptables

msg_info "Running SSL Setup..."
bash <(curl -fsSL "https://raw.githubusercontent.com/rickcollette/illuminated/main/scripts/setup_ssl_certbot.sh")

sanity_check

msg_info "Notifying Discord of successful firewall and SSL setup..."

curl -H "Content-Type: application/json" -X POST \
  -d "{\"content\": \"🛡️ Firewall rules, NAT, and SSL setup completed successfully for ${DOMAIN}\n🌐 Public IP: ${PUBLIC_IP}\n🔒 Ports forwarded: 80, 443, 25565\n✅ Containers can resolve domain correctly.\"}" \
  "$DISCORD_WEBHOOK"

msg_ok "✅ Firewall, SSL, DNS sanity, and Discord notification complete!"
