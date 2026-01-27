# Privacy Box

**One-click secure media server setup for Windows, Mac, and Linux.**

A setup script that automatically deploys a complete *arr stack (Sonarr, Radarr, Prowlarr, qBittorrent) routed through a VPN tunnel using Docker.

---

## Download & Install

| Platform | Instructions |
|----------|--------------|
| **Windows** | Download ZIP → Extract → Double-click **`Setup-PrivacyBox.bat`** |
| **macOS** | One-liner below, or download ZIP → `chmod +x setup.sh && ./setup.sh` |
| **Linux** | One-liner below, or download ZIP → `chmod +x setup.sh && ./setup.sh` |

[![Download ZIP](https://img.shields.io/badge/Download-ZIP-blue?style=for-the-badge&logo=github)](https://github.com/loponai/tomsparkprivacyarrsuite/archive/refs/heads/main.zip)

### One-Liner Install (Mac/Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/loponai/tomsparkprivacyarrsuite/main/install.sh | bash
```

> **Need a VPN?**
> - [**NordVPN**](https://nordvpn.tomspark.tech/) - 4 extra months FREE!
> - [**ProtonVPN**](https://protonvpn.tomspark.tech/) - 3 months FREE!
> - [**Surfshark**](https://surfshark.tomspark.tech/) - 3 extra months FREE!

---

## Features

- **One-click setup** - No manual file editing required
- **Cross-platform** - Works on Windows, macOS, and Linux
- **Multi-VPN support** - Works with NordVPN, ProtonVPN, or Surfshark
- **VPN Kill Switch** - All traffic routed through Gluetun
- **Jellyfin included** - Stream your media to any device out of the box
- **Pre-configured ports** - Avoids common port conflicts
- **Guided configuration** - Step-by-step instructions for connecting all apps
- **Safe defaults** - Credentials properly quoted, secure settings enabled

## What Gets Installed

| Service | Port | Description |
|---------|------|-------------|
| qBittorrent | `localhost:8080` | Torrent client |
| Prowlarr | `localhost:8181` | Indexer manager |
| Sonarr | `localhost:8989` | TV show manager |
| Radarr | `localhost:7878` | Movie manager |
| Jellyfin | `localhost:8096` | Media server (watch on any device!) |
| Gluetun | - | VPN tunnel (NordVPN/ProtonVPN/Surfshark) |

## Requirements

- **Windows 10/11**: [Docker Desktop](https://www.docker.com/products/docker-desktop/) with WSL 2
- **macOS**: [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- **Linux**: [Docker Engine](https://docs.docker.com/engine/install/) (or run `curl -fsSL https://get.docker.com | sh`)
- A VPN subscription from one of:
  - [**NordVPN**](https://nordvpn.tomspark.tech/) - 4 extra months FREE! Fastest speeds based on [RealVPNSpeeds.com](https://realvpnspeeds.com)
  - [**ProtonVPN**](https://protonvpn.tomspark.tech/) - 3 months FREE!
  - [**Surfshark**](https://surfshark.tomspark.tech/) - 3 extra months FREE!

## Quick Start

1. **Download** - Click the green "Code" button, then "Download ZIP"

   ![How to download](images/download-instructions.png)

2. **Extract** the ZIP file to your Desktop

3. **Run the setup script:**

   **Windows:**
   ```
   Double-click Setup-PrivacyBox.bat
   ```

   **Mac/Linux:**
   ```bash
   cd ~/Desktop/PrivacyServer
   chmod +x setup.sh
   ./setup.sh
   ```

4. **Follow the prompts** - the script will guide you through everything

## What You'll Need

> **⚠️ CRITICAL: VPN credentials are NOT your login email/password!**
>
> You need special "Service Credentials" from your VPN's manual setup area.
> Using your regular login WILL NOT WORK and causes AUTH_FAILED errors.

**How to get your Service Credentials:**

| VPN Provider | Credentials URL |
|--------------|-----------------|
| **NordVPN** | [my.nordaccount.com/dashboard/nordvpn/manual-configuration/](https://my.nordaccount.com/dashboard/nordvpn/manual-configuration/) |
| **ProtonVPN** | [account.proton.me/u/0/vpn/OpenVpnIKEv2](https://account.proton.me/u/0/vpn/OpenVpnIKEv2) |
| **Surfshark** | [my.surfshark.com/vpn/manual-setup/main/openvpn](https://my.surfshark.com/vpn/manual-setup/main/openvpn) |

The credentials look like random alphanumeric strings (e.g., `qVVEf1PqMaXi`) - NOT `yourname@email.com`

## Manual Commands

```bash
# Start the stack
docker compose up -d

# Stop the stack
docker compose down

# View VPN logs
docker logs gluetun

# Check container status
docker ps
```

## Troubleshooting

### AUTH_FAILED Error
**This is the #1 most common error!**
- You're using your VPN email/password instead of Service Credentials
- Your login email (`you@gmail.com`) will NOT work
- Go to your VPN provider's manual setup page (see "What You'll Need" above)
- Copy the **Service Credentials** (random alphanumeric strings, NOT your email)

### Port Already in Use
- **Windows:** Hyper-V reserves random ports in the 9000-9999 range
- **All platforms:** This script uses port 8181 for Prowlarr to avoid conflicts
- Check what's using a port: `netstat -an | grep 8080` (Mac/Linux) or `netstat -an | findstr 8080` (Windows)

### Prowlarr Shows Few Indexers
- Change the Language filter from "en-US" to "Any"
- Most indexers are tagged as "English" not "en-US"

### qBittorrent Password
qBittorrent generates a **random password** on first run (not admin/adminadmin anymore).

Find it with:
```bash
# Windows
docker logs qbittorrent 2>&1 | findstr password

# Mac/Linux
docker logs qbittorrent 2>&1 | grep password
```
Username is `admin`. Change the password after logging in.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      INTERNET                           │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│                 GLUETUN (VPN Tunnel)                    │
│         NordVPN / ProtonVPN / Surfshark                 │
│                   Your IP: Hidden                       │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐       │
│  │ qBittorrent │ │   Sonarr    │ │   Radarr    │       │
│  │   :8080     │ │   :8989     │ │   :7878     │       │
│  └─────────────┘ └─────────────┘ └─────────────┘       │
│         ┌─────────────┐                                 │
│         │  Prowlarr   │                                 │
│         │   :8181     │                                 │
│         └─────────────┘                                 │
└─────────────────────────────────────────────────────────┘

All containers share Gluetun's network = Zero IP leaks
```

## License

**MIT License with Attribution Requirement**

You are free to use, modify, and share this software, but you **MUST credit Tom Spark** in any public distribution, video, blog post, or derivative work.

**Required attribution:** `Created by Tom Spark - youtube.com/@TomSparkReviews`

Failure to attribute = DMCA takedown. See [LICENSE](LICENSE) for full terms.

## Support This Project

This project is free and open source. If you'd like to support development:

| Provider | Deal |
|----------|------|
| **[NordVPN](https://nordvpn.tomspark.tech/)** | 4 extra months FREE! Fastest speeds ([RealVPNSpeeds.com](https://realvpnspeeds.com)) |
| **[ProtonVPN](https://protonvpn.tomspark.tech/)** | 3 months FREE! Swiss privacy |
| **[Surfshark](https://surfshark.tomspark.tech/)** | 3 extra months FREE! Unlimited devices |

## Need Help?

[![Discord](https://img.shields.io/badge/Join%20Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/uPdRcKxEVS)

Questions? Join the **[Tom Spark Discord](https://discord.gg/uPdRcKxEVS)** for support!

## Credits

- [Gluetun](https://github.com/qdm12/gluetun) - VPN client
- [LinuxServer.io](https://www.linuxserver.io/) - Docker images
- Tom Spark - Original tutorial

---

**Disclaimer:** This tool is for legal purposes only. Respect copyright laws in your jurisdiction.
