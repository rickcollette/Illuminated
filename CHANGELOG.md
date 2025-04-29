# 📜 Changelog

## [1.0.10] - 2025-05-02

### Added for 1.0.10

- Added auto detection of IPs and firewalls/port forwarding

## [1.0.9] - 2025-05-02

### Added for 1.0.9

### Fixed

- fixed vmbr0->vmbr1
  
## [1.0.8] - 2025-05-02

### Added for 1.0.8

### Fixed

- added pause_for_fw to fix issue where letsencrypt is required

## [1.0.5] - 2025-05-02

### Added for 1.0.5

- shuffled around the user creation bits.

## [1.0.4] - 2025-05-02

### Added for 1.0.4

- 🧠 **Per-container disk sizing**: Each LXC now has its own disk size (e.g. 20GB for `papermc-server`, 2GB for `papermc-proxy`)
- 🔐 **Random root passwords**: Each container is created with a unique strong root password; all are saved to `papermc-server` under `/home/papermc/container-passwords.txt`
- 📄 **Access info generation**: Final service URLs and ports are saved to `/home/papermc/access-info.txt` and sent to Discord
- 💬 **Discord integration**: You can pass in `DISCORD_WEBHOOK=...` to receive install completion alerts
- 🧠 **Dynamic template support**: Fixes incompatibility with `local-lvm` by using `local` for the template and `local-lvm` for container storage
- 🗂️ **Disk/CPU/RAM definitions** split out into proper `containers_disk`, `containers_ram`, and `containers_cores` associative arrays
- 🚮 **Container destruction logic**: Now destroys and recreates containers by default unless `--skip-existing` is passed
- 🧼 **Safer backups before container recreation**: Automatically creates `zstd`-compressed backups of existing containers before re-creation
- ✅ **User creation in papermc-server**: Ensures `papermc` user and home directory exist for proper file ownership

### Changed

- 🔀 `create_containers.sh` now uses VMID-based iteration with backup-aware logic and skips if requested
- 🛡️ Updated `illuminated.sh` to default to destroy-and-recreate but allows flags like `--skip-existing`, `--reinstall-website`, and `--reinstall-bluemap`
- 🔄 Updated `setup_reverse_proxy.sh` to use dynamically retrieved IP addresses
- 🗺️ Improved `setup_bluemap.sh` with cron auto-render logic and restart call
- 📦 Modular mode switching in `illuminated.sh` based on CLI flag
- 📜 Updated LICENSE to clarify 2025 MIT terms

### Fixed

- 🧱 Proxmox template location bug (was trying to use `local-lvm` for templates)
- ❗ `papermc:papermc` chown error due to missing user (now fixed with useradd)
- 🔗 Nginx config now correctly reverse proxies to map and server with dynamic container IP support
- 🌍 All scripts now consistently reference exported variables (`$DOMAIN`, `$DISCORD_WEBHOOK`, etc.)

---

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
