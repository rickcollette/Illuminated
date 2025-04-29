#!/usr/bin/env bash
set -euo pipefail

# Require DOMAIN and DISCORD_WEBHOOK
if [[ -z "${DOMAIN:-}" || -z "${DISCORD_WEBHOOK:-}" ]]; then
  echo "❌ ERROR: You must run this script with DOMAIN and DISCORD_WEBHOOK set!"
  echo ""
  echo "Example:"
  echo "DOMAIN='mc.example.com' DISCORD_WEBHOOK='https://discord.com/api/webhooks/xxx/yyy' bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/rickcollette/illuminated/main/illuminated.sh)\""
  exit 1
fi

# Export for all sub-scripts
export DOMAIN
export DISCORD_WEBHOOK

# Load build helpers
source <(curl -fsSL https://raw.githubusercontent.com/rickcollette/illuminated/main/scripts/build.func)

APP="LouMinadiCraft Illuminated"
BRIDGE="vmbr0"
STORAGE="local-lvm"

header_info "$APP Setup"
catch_errors

BASE_URL="https://raw.githubusercontent.com/rickcollette/illuminated/main/scripts"
MODE="${1:-default}"

msg_info "Selected mode: ${MODE}"

run_script() {
  local script_name=$1
  msg_info "Running ${script_name}..."
  bash <(curl -fsSL "${BASE_URL}/${script_name}") "$MODE"
}

# Main logic
if [[ "$MODE" == "--skip-existing" ]]; then
  run_script create_containers.sh
  run_script setup_papermc_server.sh
  run_script setup_bluemap.sh
  run_script setup_backup_service.sh
  run_script setup_static_website.sh
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
  run_script setup_ssl_certbot.sh
fi

# Final Screen
clear
header_info "🎉 LouMinadiCraft Illuminated Installed Successfully!"
msg_ok "Minecraft Server ready!"
msg_ok "BlueMap ready!"
msg_ok "Static website ready!"
msg_ok "SSL secured reverse proxy ready!"

echo -e "\nAccess Your Services:"
echo -e "${CYAN}• Minecraft Server:${NC} Connect using ${DOMAIN} at port 25565"
echo -e "${CYAN}• Static Website:${NC} https://${DOMAIN}"
echo -e "${CYAN}• BlueMap:${NC} https://${DOMAIN}/map"

# Write access info
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

# Discord notification
DISCORD_MESSAGE="🎮 LouMinadiCraft Illuminated Setup Complete!

• Minecraft Server: ${DOMAIN} :25565
• Website: https://${DOMAIN}
• BlueMap: https://${DOMAIN}/map

✅ Installation Completed Successfully!"

curl -H "Content-Type: application/json" -X POST \
  -d "{\"content\": \"$DISCORD_MESSAGE\"}" "$DISCORD_WEBHOOK"
msg_ok "Sent access information to Discord!"
