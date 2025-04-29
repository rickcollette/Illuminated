# 📜 Changelog

## [1.0.3] - 2025-05-01

### Added for v1.0.3

- `illuminated.sh` now supports CLI modes: `--skip-existing`, `--reinstall-bluemap`, `--reinstall-website`
- Automatic container backups before destroy (with versioned archives)
- Automatic restoration of persistent data after reinstall
- BlueMap automatic re-render every 4 hours via cron
- Improved compression (`zstd`) and rotation (keep 7 days of backups)
- Dynamic IP detection for nginx SSL config
- Smarter container handling with "destroy-and-recreate" or "skip existing"
- Better modular structure for future updates (PaperMC, plugins, website)

### Changed

- Updated `build.func` to support dynamic messaging, backup, restore
- Updated `create_containers.sh` to support backup-aware operations
- Updated nginx templates to handle mc.DOMAIN.com structure dynamically

---

## [1.0.0] - 2025-05-01

### Added for v1.0.0

- Initial release of Illuminated
- Proxmox LXC container deployment
- Minecraft Server with LouMinadiCraft plugin
- BlueMap Live Renderer
- Static website with glowing landing page
- Reverse proxy + SSL auto setup
- Backup automation every 4 hours

---
