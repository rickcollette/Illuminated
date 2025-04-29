#!/bin/bash
set -euo pipefail

VERSION="1.0.0"

echo "🌟 Welcome to LouMinadiCraft Illuminated Setup!"
echo "🔧 Installing your Proxmox LXC Containers..."

BASE_URL="https://raw.githubusercontent.com/rickcollette/illuminated/main/scripts"

function run_script() {
    local script_name=$1
    echo "Running $script_name..."
    curl -fsSL "${BASE_URL}/${script_name}" | bash
}

run_script create_containers.sh
run_script setup_papermc_server.sh
run_script setup_bluemap.sh
run_script setup_backup_service.sh
run_script setup_static_website.sh
run_script setup_reverse_proxy.sh
run_script setup_ssl_certbot.sh

echo "✅ LouMinadiCraft Illuminated Setup Complete!"
