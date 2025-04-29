#!/bin/bash
set -euo pipefail

echo "🔒 Setting up SSL with Certbot..."

echo "⚠️  After running, manually run certbot inside the papermc-proxy container:"
echo "   pct exec 204 -- certbot --nginx -d website.yourdomain.com"

echo "✅ Certbot ready."
