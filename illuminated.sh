#!/usr/bin/env bash
set -euo pipefail

# Load build functions
source <(curl -fsSL https://raw.githubusercontent.com/rickcollette/illuminated/main/scripts/build.func)

APP="LouMinadiCraft Illuminated"
BRIDGE="vmbr0"
STORAGE="local-lvm"

header_info "$APP Setup"
catch_errors

BASE_URL="https://raw.githubusercontent.com/rickcollette/illuminated/main/scripts"

MODE="${1:-default}"  # Accept CLI argument (default if none)

msg_info "Selected mode: ${MODE}"

# Function to run a sub-script with curl
run_script() {
  local script_name=$1
  msg_info "Running ${script_name}..."
  bash <(curl -fsSL "${BASE_URL}/${script_name}") "$MODE"
}

# Flow Control based on MODE
if [[ "$MODE" == "--skip-existing" ]]; then
  run_script create_containers.sh
  run_script setup_papermc_server.sh
  run_script setup_bluemap.sh
  run_script setup_backup_service.sh
  run_script setup_static_website.sh
  run_script setup_reverse_proxy.sh
  run_script setup_ssl_certbot.sh

elif [[ "$MODE" == "--reinstall-bluemap" ]]; then
  run_script create_containers.sh
  run_script setup_bluemap.sh

elif [[ "$MODE" == "--reinstall-website" ]]; then
  run_script create_containers.sh
  run_script setup_static_website.sh

else
  # Full fresh install (default mode)
  run_script create_containers.sh
  run_script setup_papermc_server.sh
  run_script setup_bluemap.sh
  run_script setup_backup_service.sh
  run_script setup_static_website.sh
  run_script setup_reverse_proxy.sh
  run_script setup_ssl_certbot.sh
fi

# Final Success Screen
clear
header_info "🎉 LouMinadiCraft Illuminated Installed Successfully!"
msg_ok "Minecraft Server ready!"
msg_ok "BlueMap ready!"
msg_ok "Static website ready!"
msg_ok "SSL secured reverse proxy ready!"

echo -e "\nAccess Your Services:"
echo -e "${CYAN}• Minecraft Server:${NC} Connect using your domain/IP at port 25565"
echo -e "${CYAN}• Static Website:${NC} https://mc.yourdomain.com"
echo -e "${CYAN}• BlueMap:${NC} https://mc.yourdomain.com/map"

echo -e "\n${GREEN}Installation Completed Successfully!${NC}\n"
