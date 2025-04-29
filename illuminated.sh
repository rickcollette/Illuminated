#!/usr/bin/env bash
set -euo pipefail

export VERSION="1.0.8"

# Require DOMAIN and DISCORD_WEBHOOK
if [[ -z "${DOMAIN:-}" || -z "${DISCORD_WEBHOOK:-}" ]]; then
  echo "❌ ERROR: You must run this script with DOMAIN and DISCORD_WEBHOOK set!"
  echo ""
  echo "Example:"
  echo "DOMAIN='mc.example.com' DISCORD_WEBHOOK='https://discord.com/api/webhooks/xxx/yyy' bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/rickcollette/illuminated/main/illuminated.sh)\""
  exit 1
fi

# Export for sub-scripts
export DOMAIN
export DISCORD_WEBHOOK
export TEMPLATE_STORAGE="local"
export STORAGE="local-lvm"
export BRIDGE="vmbr0"

# Load build helpers
source <(curl -fsSL https://raw.githubusercontent.com/rickcollette/illuminated/main/scripts/build.func)

APP="LouMinadiCraft Illuminated v${VERSION}"
header_info "$APP Setup"
catch_errors

BASE_URL="https://raw.githubusercontent.com/rickcollette/illuminated/main/scripts"
MODE="${1:-default}"
msg_info "Selected mode: ${MODE}"

pause_for_fw() {
  # Show internal IPs of all containers before requesting SSL
header_info "📡 Internal IP Addresses (configure your firewall/NAT before continuing)"

for CTID in 200 201 202 203 204; do
  NAME=$(pct config $CTID | grep -i hostname | awk '{print $2}')
  IP=$(get_container_ip "$CTID")
  echo -e "${CYAN}• ${NAME}:${NC} $IP"
done

echo -e "\n${YELLOW}🔒 Ensure DNS A/AAAA records for ${DOMAIN} point to your public IP."
echo -e "🧱 Ensure port 80/443 is forwarded to papermc-proxy container (${CYAN}CTID 204${NC})\n"
read -rp "🚀 Press Enter to continue with SSL setup, or Ctrl+C to abort..."
}

run_script() {
  local script_name=$1
  msg_info "Running ${script_name}..."
  bash <(curl -fsSL "${BASE_URL}/${script_name}") "$MODE"
}

# Mode-based logic
if [[ "$MODE" == "--skip-existing" ]]; then
  run_script create_containers.sh
  run_script setup_papermc_server.sh
  run_script setup_bluemap.sh
  run_script setup_backup_service.sh
  run_script setup_static_website.sh
  pause_for_fw
  run_script setup_reverse_proxy.sh
  run_script setup_ssl_certbot.sh
elif [[ "$MODE" == "--reinstall-bluemap" ]]; then
  run_script setup_bluemap.sh
elif [[ "$MODE" == "--reinstall-website" ]]; then
  run_script setup_static_website.sh
else
  run_script create_containers.sh
  run_script setup_papermc_server.sh
  run_script setup_bluemap.sh
  run_script setup_backup_service.sh
  run_script setup_static_website.sh
  run_script setup_reverse_proxy.sh
  pause_for_fw
  run_script setup_ssl_certbot.sh
fi

# Final screen
clear
header_info "🎉 LouMinadiCraft Illuminated v${VERSION} Installed Successfully!"
msg_ok "Minecraft Server ready!"
msg_ok "BlueMap ready!"
msg_ok "Static website ready!"
msg_ok "SSL secured reverse proxy ready!"

echo -e "\nAccess Your Services:"
echo -e "${CYAN}• Minecraft Server:${NC} Connect using ${DOMAIN} at port 25565"
echo -e "${CYAN}• Static Website:${NC} https://${DOMAIN}"
echo -e "${CYAN}• BlueMap:${NC} https://${DOMAIN}/map"

ACCESS_FILE="/home/papermc/access-info.txt"
mkdir -p "$(dirname "$ACCESS_FILE")"
cat > "$ACCESS_FILE" <<EOF
🎮 LouMinadiCraft Illuminated Access Info

Minecraft Server: ${DOMAIN} :25565
Static Website: https://${DOMAIN}
BlueMap: https://${DOMAIN}/map

Installation Time: $(date)
EOF

msg_ok "Saved access information to ${ACCESS_FILE}"

curl -H "Content-Type: application/json" -X POST \
  -d "{\"content\": \"🎮 LouMinadiCraft Illuminated Setup Complete!\n• Minecraft Server: ${DOMAIN} :25565\n• Website: https://${DOMAIN}\n• BlueMap: https://${DOMAIN}/map\n✅ Installation Completed Successfully!\"}" \
  "$DISCORD_WEBHOOK"
msg_ok "Sent access information to Discord!"
