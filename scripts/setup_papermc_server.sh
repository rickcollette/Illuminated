#!/bin/bash
set -euo pipefail

echo "🎮 Setting up PaperMC server..."

# Install Java and curl
pct exec 200 -- bash -c "
  apt update &&
  apt install -y openjdk-17-jre-headless curl unzip &&
  mkdir -p /papermc/plugins &&
  curl -Lo /papermc/paper.jar https://api.papermc.io/v2/projects/paper/versions/1.21.5/builds/41/downloads/paper-1.21.5-41.jar &&
  echo 'eula=true' > /papermc/eula.txt
"

echo "📦 Installing essential plugins..."

# Install plugins automatically
pct exec 200 -- bash -c "
  cd /papermc/plugins &&
  
  # Multiverse Core
  curl -Lo Multiverse-Core.jar https://hangar.papermc.io/api/v1/projects/Multiverse/Multiverse-Core/versions/latest/download &&

  # DirectionHUD
  curl -Lo DirectionHUD.jar https://hangar.papermc.io/api/v1/projects/other/DirectionHUD/versions/latest/download &&

  # GriefPrevention
  curl -Lo GriefPrevention.jar https://hangar.papermc.io/api/v1/projects/GriefPrevention/GriefPrevention/versions/latest/download &&

  # Machines
  curl -Lo Machines.jar https://hangar.papermc.io/api/v1/projects/xenondevs/Machines/versions/latest/download &&

  # SimplePets
  curl -Lo SimplePets.jar https://hangar.papermc.io/api/v1/projects/BSDevelopment/SimplePets/versions/latest/download &&

  # Jetpacks
  curl -Lo Jetpacks.jar https://hangar.papermc.io/api/v1/projects/xenondevs/Jetpacks/versions/latest/download &&

  # Coordinates
  curl -Lo Coordinates.jar https://hangar.papermc.io/api/v1/projects/Maledict/Coordinates/versions/latest/download
"

echo "✅ Plugins installed!"
