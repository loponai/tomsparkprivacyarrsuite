# Privacy Box

**One-click secure media server setup for Windows, Mac, and Linux.**

A setup script that automatically deploys a complete *arr stack (Sonarr, Radarr, Prowlarr, qBittorrent) routed through a VPN tunnel using Docker.

---

## Download & Install

[![Download ZIP](https://img.shields.io/badge/Download-ZIP-blue?style=for-the-badge&logo=github)](https://github.com/loponai/tomsparkprivacyarrsuite/archive/refs/heads/main.zip)

> **Need a VPN?** NordVPN, ProtonVPN, or Surfshark are all supported. See [What You'll Need](#what-youll-need) below.

<details>
<summary><b>Windows (Docker Desktop) - Recommended for beginners</b></summary>

### Prerequisites
1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/)
2. During installation, make sure **"Use WSL 2"** is checked
3. Start Docker Desktop and wait for the whale icon to turn green

### Install
1. Download the ZIP (button above)
2. Extract to your Desktop
3. Double-click **`Setup-PrivacyBox.bat`**
4. Follow the prompts

</details>

<details>
<summary><b>Windows (WSL2 Native) - Power users, lower resource usage</b></summary>

### Prerequisites
1. Open PowerShell as Admin and run: `wsl --install`
2. Restart your computer
3. Open Ubuntu (or your WSL2 distro) and install Docker:
   ```bash
   curl -fsSL https://get.docker.com | sh
   sudo usermod -aG docker $USER
   ```
4. Restart WSL2: Run `wsl --shutdown` in PowerShell, then reopen Ubuntu

### Install
**Option A - One-liner:**
```bash
curl -fsSL https://raw.githubusercontent.com/loponai/tomsparkprivacyarrsuite/main/install.sh | bash
```

**Option B - Manual:**
1. Download and extract the ZIP
2. In WSL2 terminal, navigate to the folder and run:
   ```bash
   chmod +x setup.sh && ./setup.sh
   ```

**Benefits:** Lower memory usage, fewer firewall issues, no Docker Desktop license concerns

</details>

<details>
<summary><b>macOS</b></summary>

### Prerequisites
1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/)
2. Start Docker Desktop and wait for it to be ready

### Install
**Option A - One-liner:**
```bash
curl -fsSL https://raw.githubusercontent.com/loponai/tomsparkprivacyarrsuite/main/install.sh | bash
```

**Option B - Manual:**
1. Download and extract the ZIP
2. Open Terminal, navigate to the folder, and run:
   ```bash
   chmod +x setup.sh && ./setup.sh
   ```

</details>

<details>
<summary><b>Linux</b></summary>

### Prerequisites
Install Docker Engine:
```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
```
Log out and back in (or run `newgrp docker`)

### Install
**Option A - One-liner:**
```bash
curl -fsSL https://raw.githubusercontent.com/loponai/tomsparkprivacyarrsuite/main/install.sh | bash
```

**Option B - Manual:**
1. Download and extract the ZIP
2. Run:
   ```bash
   chmod +x setup.sh && ./setup.sh
   ```

</details>

> **Just want a torrent client?** Check out [**OneShotTorrent**](https://github.com/loponai/oneshottorrent) - a simpler VPN-protected qBittorrent setup without the *arr automation.

---

## Features

- **One-click setup** - No manual file editing required
- **Cross-platform** - Works on Windows, macOS, and Linux
- **Multi-VPN support** - NordVPN, ProtonVPN, Surfshark + Mullvad, PIA, Windscribe, and more
- **OpenVPN & WireGuard** - Choose your protocol (WireGuard for ProtonVPN/Surfshark)
- **VPN Kill Switch** - All traffic routed through Gluetun
- **Jellyfin included** - Stream your media to any device out of the box
- **Discord notifications** - Optional Notifiarr integration for download alerts
- **FlareSolverr support** - Optional Cloudflare bypass for protected indexers
- **Usenet support** - Optional SABnzbd for Usenet downloads
- **Music management** - Optional Lidarr for automatic music organization
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
| SABnzbd | `localhost:8085` | Usenet download client (optional) |
| Lidarr | `localhost:8686` | Music manager (optional) |
| Notifiarr | `localhost:5454` | Discord notifications (optional) |
| FlareSolverr | `localhost:8191` | Cloudflare bypass proxy (optional) |
| Gluetun | - | VPN tunnel (NordVPN/ProtonVPN/Surfshark + other providers) |

## What You'll Need

> **⚠️ CRITICAL: VPN credentials are NOT your login email/password!**
>
> You need special "Service Credentials" from your VPN's manual setup area.
> Using your regular login WILL NOT WORK and causes AUTH_FAILED errors.

### OpenVPN Credentials (Default)

| VPN Provider | Credentials URL |
|--------------|-----------------|
| **NordVPN** | [my.nordaccount.com/dashboard/nordvpn/manual-configuration/](https://my.nordaccount.com/dashboard/nordvpn/manual-configuration/) |
| **ProtonVPN** | [account.proton.me/u/0/vpn/OpenVpnIKEv2](https://account.proton.me/u/0/vpn/OpenVpnIKEv2) |
| **Surfshark** | [my.surfshark.com/vpn/manual-setup/main/openvpn](https://my.surfshark.com/vpn/manual-setup/main/openvpn) |

The credentials look like random alphanumeric strings (e.g., `qVVEf1PqMaXi`) - NOT `yourname@email.com`

### WireGuard Credentials (ProtonVPN & Surfshark only)

WireGuard is a faster, more modern VPN protocol. If you choose WireGuard during setup, you'll need:

| VPN Provider | WireGuard Setup URL |
|--------------|---------------------|
| **ProtonVPN** | [account.proton.me/u/0/vpn/WireGuard](https://account.proton.me/u/0/vpn/WireGuard) |
| **Surfshark** | [my.surfshark.com/vpn/manual-setup/main/wireguard](https://my.surfshark.com/vpn/manual-setup/main/wireguard) |

**What you need from WireGuard config:**
- **Private Key** - A base64 string (e.g., `yAnz5TF+lXXJte14tji3zlMNq+hd2rYUIgJBgB3fBmk=`)
- **Address** - Your assigned IP (e.g., `10.2.0.2/32`)

### Other VPN Providers

The setup script also supports **Mullvad**, **Private Internet Access (PIA)**, **Windscribe**, **CyberGhost**, **IPVanish**, **AirVPN**, and any other [Gluetun-supported provider](https://github.com/qdm12/gluetun-wiki/tree/main/setup/providers). Select "Other VPN provider" during setup and follow the prompts. You'll need your provider's service/manual credentials — check your provider's account page for details.

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

# Enable Notifiarr (Discord notifications)
# First add NOTIFIARR_API_KEY=your-key to .env, then:
docker compose --profile notifications up -d

# Enable FlareSolverr (Cloudflare bypass for indexers)
docker compose --profile flaresolverr up -d

# Enable SABnzbd (Usenet downloads)
docker compose --profile sabnzbd up -d

# Enable Lidarr (music management)
docker compose --profile lidarr up -d
```

## Discord Notifications (Notifiarr)

Want to get notified on Discord when downloads start, complete, or when new episodes are available? [Notifiarr](https://notifiarr.com) sends beautiful notifications to your Discord server.

**The setup script will ask if you want this at the end.** If you skipped it or want to add it later:

### Enable Notifiarr

1. **Create a free account** at [notifiarr.com](https://notifiarr.com) (sign in with Discord recommended)

2. **Copy your API Key** from your Notifiarr profile

3. **Add the API key** to your `.env` file:
   ```
   NOTIFIARR_API_KEY=your-api-key-here
   ```

4. **Start Notifiarr:**
   ```bash
   docker compose --profile notifications up -d
   ```

5. **Open Notifiarr** at `http://localhost:5454`
   - Username: `admin`
   - Password: your API key

### Connect Your Apps

In the Notifiarr web UI (`localhost:5454`):
1. Go to **Starr Apps**
2. Add **Radarr**: URL `http://localhost:7878`, API key from Radarr > Settings > General
3. Add **Sonarr**: URL `http://localhost:8989`, API key from Sonarr > Settings > General

On [notifiarr.com](https://notifiarr.com):
1. Go to **Integrations > Manage**
2. Enable Radarr/Sonarr integrations
3. Set up your Discord channel for notifications

That's it! You'll now get Discord alerts for grabs, downloads, upgrades, and more.

## Cloudflare Bypass (FlareSolverr)

Some indexers use Cloudflare anti-bot protection which blocks automated access. [FlareSolverr](https://github.com/FlareSolverr/FlareSolverr) runs a headless browser to solve these challenges automatically.

**The setup script will ask if you want this at the end.** If you skipped it or want to add it later:

### Enable FlareSolverr

1. **Start FlareSolverr:**
   ```bash
   docker compose --profile flaresolverr up -d
   ```

2. **Configure in Prowlarr:**
   - Open Prowlarr at `http://localhost:8181`
   - Go to **Settings > Indexers**
   - Click **+** under "Indexer Proxies"
   - Select **FlareSolverr**
   - Set Host to: `http://flaresolverr:8191`
   - Click **Test** then **Save**

Prowlarr will now automatically route requests through FlareSolverr when indexers require Cloudflare bypass. No API key or account needed.

## Usenet Downloads (SABnzbd)

[SABnzbd](https://sabnzbd.org/) is a Usenet download client — an alternative to torrents. Usenet downloads are SSL-encrypted and typically faster. You'll need a Usenet provider subscription (e.g., Newshosting, Eweka).

**The setup script will ask if you want this at the end.** If you skipped it or want to add it later:

### Enable SABnzbd

1. **Start SABnzbd:**
   ```bash
   docker compose --profile sabnzbd up -d
   ```

2. **Open SABnzbd** at `http://localhost:8085` and follow the Quick-Start Wizard

3. **Add your Usenet provider** (host, port, username, API key from your provider)

4. **Use SABnzbd as a download client** in Sonarr/Radarr/Lidarr:
   - Settings > Download Clients > + > SABnzbd
   - Host: `sabnzbd`, Port: `8080`
   - API Key: from SABnzbd > Config > General

## Music Management (Lidarr)

[Lidarr](https://lidarr.audio/) automatically finds, downloads, and organizes music — just like Sonarr for TV and Radarr for movies. Your music will be available in Jellyfin for streaming.

**The setup script will ask if you want this at the end.** If you skipped it or want to add it later:

### Enable Lidarr

1. **Start Lidarr:**
   ```bash
   docker compose --profile lidarr up -d
   ```

2. **Open Lidarr** at `http://localhost:8686` and create your admin account

3. **Set root folder** to `/data/media/music` (Settings > Media Management > Add Root Folder)

4. **Add download client:** Settings > Download Clients > + > qBittorrent (Host: `localhost`, Port: `8080`)

5. **Connect in Prowlarr:** Settings > Apps > + > Lidarr (Server: `http://localhost:8686`, add API key)

6. **Add music library in Jellyfin:** Content type "Music", folder `/data/music`

## Troubleshooting

### AUTH_FAILED Error (OpenVPN)
**This is the #1 most common error!**
- You're using your VPN email/password instead of Service Credentials
- Your login email (`you@gmail.com`) will NOT work
- Go to your VPN provider's manual setup page (see "What You'll Need" above)
- Copy the **Service Credentials** (random alphanumeric strings, NOT your email)

### WireGuard Connection Failed
If using WireGuard and the VPN won't connect:
- Make sure you copied the **Private Key** correctly (it's a long base64 string ending in `=`)
- Verify the **Address** matches what was shown in your config (e.g., `10.2.0.2/32`)
- Try generating a new WireGuard configuration from your VPN provider
- Check that `VPN_TYPE=wireguard` is set in your `.env` file

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
└───────────┬─────────────────────────────┬───────────────┘
            │                             │
            ▼                             ▼
┌───────────────────────────────────┐  ┌──────────────┐
│       GLUETUN (VPN Tunnel)        │  │   SABnzbd*   │
│  NordVPN / ProtonVPN / Surfshark  │  │    :8085     │
│         Your IP: Hidden           │  │  (SSL/own    │
├───────────────────────────────────┤  │   network)   │
│ ┌───────────┐ ┌───────┐ ┌───────┐│  └──────────────┘
│ │qBittorrent│ │ Sonarr│ │Radarr ││
│ │  :8080    │ │ :8989 │ │ :7878 ││  ┌──────────────┐
│ └───────────┘ └───────┘ └───────┘│  │   Jellyfin   │
│ ┌───────────┐ ┌───────┐         ││  │    :8096     │
│ │ Prowlarr  │ │Lidarr*│         ││  │  (Media      │
│ │  :8181    │ │ :8686 │         ││  │   Server)    │
│ └───────────┘ └───────┘         ││  └──────────────┘
└───────────────────────────────────┘
                                      * = optional
All VPN containers share Gluetun's network = Zero IP leaks
```

## Remote Access with Tailscale

Want to access your media server from anywhere — your phone, a laptop at a coffee shop, or a family member's house? [Tailscale](https://tailscale.com/) creates a private, encrypted network between your devices with zero configuration.

### Install Tailscale on the machine running Privacy Box

```bash
curl -fsSL https://tailscale.com/install.sh | sh && sudo tailscale up
```

### Access your apps from anywhere

Once Tailscale is running, access Jellyfin, Sonarr, Radarr, and all other services using your machine's Tailscale IP (shown after `tailscale up`):

- Jellyfin: `http://[tailscale-ip]:8096`
- Sonarr: `http://[tailscale-ip]:8989`
- Radarr: `http://[tailscale-ip]:7878`
- qBittorrent: `http://[tailscale-ip]:8080`

### Share with family

Use [Tailscale node sharing](https://tailscale.com/kb/1084/sharing) to give family members access to your Jellyfin server without exposing anything to the public internet.

### Expose Jellyfin publicly (optional)

If you want anyone to access Jellyfin without installing Tailscale:

```bash
tailscale funnel 8096
```

This gives you a public HTTPS URL with automatic SSL — no port forwarding, no domain purchase, no reverse proxy setup needed.

### Run on a home PC instead of a VPS

With Tailscale, there is no need to pay for a VPS. You can run the full Privacy Box stack on a spare home PC, NUC, or mini server and access it from anywhere through your Tailscale network. This saves you a monthly hosting bill while keeping everything private.

## License

**MIT License with Attribution Requirement**

You are free to use, modify, and share this software, but you **MUST credit Tom Spark** in any public distribution, video, blog post, or derivative work.

**Required attribution:** `Created by Tom Spark - youtube.com/@TomSparkReviews`

Failure to attribute = DMCA takedown. See [LICENSE](LICENSE) for full terms.

## Need Help?

[![Discord](https://img.shields.io/badge/Join%20Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/uPdRcKxEVS)

Questions? Join the **[Tom Spark Discord](https://discord.gg/uPdRcKxEVS)** for support!

## Credits

- [Gluetun](https://github.com/qdm12/gluetun) - VPN client
- [LinuxServer.io](https://www.linuxserver.io/) - Docker images
- [Notifiarr](https://notifiarr.com) - Discord notifications
- [FlareSolverr](https://github.com/FlareSolverr/FlareSolverr) - Cloudflare bypass proxy
- [SABnzbd](https://sabnzbd.org/) - Usenet download client
- [Lidarr](https://lidarr.audio/) - Music manager
- Tom Spark - Original tutorial

---

**Disclaimer:** This tool is for legal purposes only. Respect copyright laws in your jurisdiction.
