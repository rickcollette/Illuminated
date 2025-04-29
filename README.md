# LouMinadiCraft Illuminated 🚀

<div align="center">
  <img src="https://img.shields.io/badge/Proxmox-Ready-brightgreen?style=for-the-badge" alt="Proxmox Ready">
  <img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge" alt="License: MIT">
  <img src="https://img.shields.io/badge/Install-One--Click-success?style=for-the-badge" alt="One Click Install">
  <img src="https://img.shields.io/badge/Version-1.0.0-orange?style=for-the-badge" alt="Version 1.0.0">
</div>

---

Welcome to **Illuminated** — the complete Proxmox LXC-based deployment stack for building and running your **LouMinadiCraft** Minecraft server experience.

This project automates everything needed to host a professional-grade server featuring:

- 🛡️ Custom PaperMC Minecraft Server
- 🗺️ Live 3D BlueMap World Renderer
- 💾 Automatic World + Plugin Backups
- 🌐 Glowing Landing Page Website
- 🔒 HTTPS Reverse Proxy with Let's Encrypt SSL
- 🌟 **Custom LouMinadiCraft Plugin** — a handcrafted world full of new biomes, treasures, and adventures!

---

## 🚀 Install (One Command)

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/rickcollette/illuminated/main/illuminated.sh)"
```

> **Run this directly on your Proxmox VE node!**

---

## ♻️ Upgrade to Newer Versions

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/rickcollette/illuminated/main/illuminated.sh)"
```

✅ Safe upgrade of services, plugins, and containers.

---

## 🛠️ What It Creates

| Service | Container Name | Purpose |
|:---|:---|:---|
| Minecraft Server | `papermc-server` | Runs your LouMinadiCraft Minecraft server |
| BlueMap Renderer | `papermc-bluemap` | Renders 3D live maps of your world |
| Backup Service | `papermc-backups` | Creates compressed backups every 4 hours |
| Static Website | `papermc-website` | Serves your glowing website |
| Reverse Proxy | `papermc-proxy` | Terminates SSL and routes incoming traffic securely |

---

## 🌟 About the **LouMinadiCraft Plugin**

The heart of Illuminated is the **LouMinadiCraft** plugin — a **custom-built PaperMC plugin** that reimagines your Minecraft world.

> LouMinadiCraft transforms Minecraft into a **beautiful, adventurous, illuminated realm**.

- 🌎 New Biomes
- 🏰 Secret Structures
- 🛡️ Custom Items
- ⚔️ Adventure Systems
- 🛠️ Performance Optimizations
- 🌟 Full BlueMap Support

---

## ✨ Showcasing LouMinadiCraft Features

| Feature | Description |
|:---|:---|
| 🌎 Custom Biomes | Unique handcrafted biomes: Crystal Plains, Shadowed Forest, Ember Highlands |
| 🏰 Custom Structures | Temples, ruins, underground cities hidden across the world |
| ⚡ Enhanced World Generation | Floating islands, smarter ravines, lush caves |
| 🛡️ Custom Items | Legendary artifacts and specialized gear |
| ⚔️ Adventure Mechanics | Quests, dungeons, rare loot events |
| 🚀 Lightweight Performance | Designed for fast, smooth multiplayer play |
| 🌟 Full BlueMap Support | Biomes and structures visible in BlueMap live view |

---

## 📋 Requirements

- Proxmox VE 7.x or 8.x
- Ubuntu 24.04 LXC templates
- Public DNS records for your domain
- NAT/Firewall rules for ports 80, 443, 25565
- At least 16GB RAM recommended for smooth server and map rendering

---

## 📜 How It Works

- Creates modular LXC containers
- Installs dependencies and core services
- Deploys PaperMC server with LouMinadiCraft plugin
- Installs BlueMap renderer
- Configures backup automation
- Deploys static website and HTTPS
- Modular architecture for future upgrades

---

## 📚 Advanced Usage

- Add plugins easily
- Customize nginx reverse proxy
- Deploy additional containers (e.g., dynmap, statistics server)
- Scale with Proxmox clustering

---

## 🛡️ Security Notice

Only the **reverse proxy container** (`papermc-proxy`) is exposed publicly.
All backend services remain **shielded inside Proxmox private network**.

---

## ✨ Screenshots

<p align="center">
  <img src="https://yourdomain.com/screenshots/banner.png" width="800" alt="Banner">
</p>

<p align="center">
  <img src="https://yourdomain.com/screenshots/landing-demo.gif" width="700" alt="Landing Page Demo">
</p>

<p align="center">
  <img src="https://yourdomain.com/screenshots/bluemap-demo.gif" width="700" alt="BlueMap Live View">
</p>

---

## 🤝 Contributing

Pull requests and suggestions welcome!  
Expand LouMinadiCraft, add themes, build new adventures!

---

## 📜 License

This project is licensed under the **MIT License** — free for commercial or personal use.

---

**Built with ❤️ by [Rick Collette](https://github.com/rickcollette)**

```

---

**Credit where it is due: Thank you <https://louminardiscornfarm.com/> for having an amazing name.**
