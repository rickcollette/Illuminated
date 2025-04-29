#!/usr/bin/env bash
set -euo pipefail

source <(curl -fsSL https://raw.githubusercontent.com/rickcollette/illuminated/main/scripts/build.func)

APP="LouMinadiCraft Illuminated"
BRIDGE="vmbr0"
STORAGE="local"

header_info "$APP Setup"
catch_errors

BASE_URL="https://raw.githubusercontent.com/rickcollette/illuminated/main/scripts"

function run_script() {
  local script_name=$1
  msg_info "Running $script_name..."
  bash <(curl -fsSL "${BASE_URL}/${script_name}")
}

# Install flow
run_script create_containers.sh
run_script setup_papermc_server.sh
run_script setup_bluemap.sh
run_script setup_backup_service.sh
run_script setup_static_website.sh
run_script setup_reverse_proxy.sh
run_script setup_ssl_certbot.sh

# Final Success Screen
clear
header_info "🎉 LouMinadiCraft Illuminated Installed Successfully!"
msg_ok "Minecraft Server ready!"
msg_ok "BlueMap ready!"
msg_ok "Static website ready!"
msg_ok "SSL secured reverse proxy ready!"

echo -e "\nAccess Your Services:"
echo -e "${CYAN}• Minecraft Server:${NC} Connect using your domain/IP at port 25565"
echo -e "${CYAN}• Static Website:${NC} https://yourdomain.com"
echo -e "${CYAN}• BlueMap:${NC} https://yourdomain.com/map"

echo -e "\n${GREEN}Installation Completed Successfully!${NC}\n"
