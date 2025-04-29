#!/bin/bash
set -euo pipefail

echo "🎮 Setting up PaperMC server..."

pct exec 200 -- bash -c "
  apt update &&
  apt install -y openjdk-17-jre-headless curl unzip &&
  mkdir -p /papermc/plugins &&
  curl -Lo /papermc/paper.jar https://api.papermc.io/v2/projects/paper/versions/1.21.5/builds/41/downloads/paper-1.21.5-41.jar &&
  echo 'eula=true' > /papermc/eula.txt
"

echo "✅ PaperMC server base installed."
