#!/bin/bash
set -euo pipefail

echo "🗺️ Setting up BlueMap Renderer..."

pct exec 202 -- bash -c "
  apt update &&
  apt install -y openjdk-17-jre-headless curl &&
  mkdir -p /data &&
  curl -Lo /data/bluemap.jar https://hangar.papermc.io/api/v1/projects/Blue/BlueMap/versions/latest/download
"

echo "✅ BlueMap installed."
