# ============================================================
# PRIVACY BOX - One-Click Media Server Setup
# Created by Tom Spark | https://youtube.com/@TomSparkReviews
#
# LICENSE: MIT with Attribution - You MUST credit Tom Spark
#          if you share, modify, or create content based on this.
#
# VPN Options:
#   NordVPN:   nordvpn.tomspark.tech   (4 extra months FREE!)
#   ProtonVPN: protonvpn.tomspark.tech (3 months FREE!)
#   Surfshark: surfshark.tomspark.tech (3 extra months FREE!)
# GitHub: https://github.com/loponai/tomsparkprivacyarrsuite
# ============================================================

param(
    [switch]$SkipDockerCheck,
    [string]$InstallPath = "$env:USERPROFILE\Desktop\PrivacyServer"
)

# --- Configuration ---
$script:Version = "1.0.0"
$script:DefaultPorts = @{
    qBittorrent = 8080
    Prowlarr    = 8181  # Safe port (avoids Hyper-V conflicts)
    Sonarr      = 8989
    Radarr      = 7878
}

# --- Helper Functions ---
function Write-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "  =====================================================" -ForegroundColor Cyan
    Write-Host "       PRIVACY BOX - Secure Media Server Setup" -ForegroundColor White
    Write-Host "  =====================================================" -ForegroundColor Cyan
    Write-Host "         Created by " -ForegroundColor DarkGray -NoNewline
    Write-Host "TOM SPARK" -ForegroundColor Yellow -NoNewline
    Write-Host " | v$script:Version" -ForegroundColor DarkGray
    Write-Host "      YouTube: youtube.com/@TomSparkReviews" -ForegroundColor DarkGray
    Write-Host "      VPN Deals: " -ForegroundColor DarkGray -NoNewline
    Write-Host "nordvpn.tomspark.tech | protonvpn.tomspark.tech | surfshark.tomspark.tech" -ForegroundColor Cyan
    Write-Host "  =====================================================" -ForegroundColor Cyan
    Write-Host "   (c) 2026 Tom Spark. Licensed under MIT+Attribution." -ForegroundColor DarkGray
    Write-Host "   Unauthorized copying without credit = DMCA takedown." -ForegroundColor DarkRed
    Write-Host "  =====================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$Number, [string]$Text)
    Write-Host "  [$Number] " -ForegroundColor Yellow -NoNewline
    Write-Host $Text -ForegroundColor White
}

function Write-Success {
    param([string]$Text)
    Write-Host "  [OK] " -ForegroundColor Green -NoNewline
    Write-Host $Text -ForegroundColor White
}

function Write-Error-Custom {
    param([string]$Text)
    Write-Host "  [X] " -ForegroundColor Red -NoNewline
    Write-Host $Text -ForegroundColor White
}

function Write-Info {
    param([string]$Text)
    Write-Host "  [i] " -ForegroundColor Cyan -NoNewline
    Write-Host $Text -ForegroundColor Gray
}

function Write-Warning-Custom {
    param([string]$Text)
    Write-Host "  [!] " -ForegroundColor Yellow -NoNewline
    Write-Host $Text -ForegroundColor White
}

function Press-Enter {
    Write-Host ""
    Write-Host "  Press ENTER to continue..." -ForegroundColor DarkGray
    Read-Host | Out-Null
}

function Ask-YesNo {
    param([string]$Question)
    Write-Host ""
    Write-Host "  $Question (Y/N): " -ForegroundColor Yellow -NoNewline
    $response = Read-Host
    return $response -match "^[Yy]"
}

# --- Pre-Flight Checks ---
function Test-DockerInstalled {
    Write-Step "1" "Checking if Docker Desktop is installed..."

    $dockerPath = Get-Command docker -ErrorAction SilentlyContinue
    if (-not $dockerPath) {
        Write-Error-Custom "Docker is NOT installed!"
        Write-Host ""
        Write-Host "  Please install Docker Desktop first:" -ForegroundColor White
        Write-Host "  https://www.docker.com/products/docker-desktop/" -ForegroundColor Cyan
        Write-Host ""
        Write-Warning-Custom "During installation, make sure 'Use WSL 2' is CHECKED!"
        return $false
    }
    Write-Success "Docker is installed"
    return $true
}

function Test-DockerRunning {
    Write-Step "2" "Checking if Docker is running..."

    try {
        $result = docker info 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Docker not running"
        }
        Write-Success "Docker is running"
        return $true
    }
    catch {
        Write-Error-Custom "Docker is NOT running!"
        Write-Host ""
        Write-Host "  Please start Docker Desktop and wait for the whale icon" -ForegroundColor White
        Write-Host "  in the system tray to turn GREEN before continuing." -ForegroundColor White
        return $false
    }
}

# --- VPN Provider Selection ---
function Get-VPNProvider {
    Write-Banner
    Write-Host "  STEP 1: CHOOSE YOUR VPN" -ForegroundColor Magenta
    Write-Host "  -----------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Which VPN provider do you use?" -ForegroundColor White
    Write-Host ""
    Write-Host "    1. NordVPN" -ForegroundColor Green -NoNewline
    Write-Host "     - nordvpn.tomspark.tech " -ForegroundColor Gray -NoNewline
    Write-Host "(4 extra months FREE!)" -ForegroundColor Green
    Write-Host "    2. ProtonVPN" -ForegroundColor Cyan -NoNewline
    Write-Host "   - protonvpn.tomspark.tech " -ForegroundColor Gray -NoNewline
    Write-Host "(3 months FREE!)" -ForegroundColor Cyan
    Write-Host "    3. Surfshark" -ForegroundColor Yellow -NoNewline
    Write-Host "   - surfshark.tomspark.tech " -ForegroundColor Gray -NoNewline
    Write-Host "(3 extra months FREE!)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Select (1-3) [default: 1]: " -ForegroundColor Yellow -NoNewline
    $choice = Read-Host

    switch ($choice) {
        "2" {
            return @{
                Provider = "protonvpn"
                Name = "ProtonVPN"
                URL = "https://account.proton.me/u/0/vpn/OpenVpnIKEv2"
                Affiliate = "https://protonvpn.tomspark.tech/"
                Bonus = "3 months FREE"
            }
        }
        "3" {
            return @{
                Provider = "surfshark"
                Name = "Surfshark"
                URL = "https://my.surfshark.com/vpn/manual-setup/main/openvpn"
                Affiliate = "https://surfshark.tomspark.tech/"
                Bonus = "3 extra months FREE"
            }
        }
        default {
            return @{
                Provider = "nordvpn"
                Name = "NordVPN"
                URL = "https://my.nordaccount.com/dashboard/nordvpn/manual-configuration/"
                Affiliate = "https://nordvpn.tomspark.tech/"
                Bonus = "4 extra months FREE"
            }
        }
    }
}

# --- Credential Collection ---
function Get-VPNCredentials {
    param([hashtable]$VPN)

    Write-Banner
    Write-Host "  STEP 2: VPN CREDENTIALS" -ForegroundColor Magenta
    Write-Host "  -----------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Warning-Custom "You need $($VPN.Name) 'Service Credentials' (NOT your email/password!)"
    Write-Host ""
    Write-Host "  How to get them:" -ForegroundColor White
    Write-Host "  1. Go to: " -ForegroundColor Gray -NoNewline
    Write-Host $VPN.URL -ForegroundColor Cyan
    Write-Host "  2. Look for 'Manual Setup' or 'OpenVPN' credentials" -ForegroundColor Gray
    Write-Host "  3. Copy the Username and Password shown there" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Don't have $($VPN.Name)? Get $($VPN.Bonus)!" -ForegroundColor Green
    Write-Host "  $($VPN.Affiliate)" -ForegroundColor Cyan
    Write-Host ""

    if (Ask-YesNo "Open $($VPN.Name) credential page in your browser now?") {
        Start-Process $VPN.URL
        Write-Host ""
        Write-Info "Browser opened. Copy your credentials, then come back here."
        Press-Enter
    }

    Write-Host ""
    Write-Host "  Enter your Service Username: " -ForegroundColor Yellow -NoNewline
    $username = Read-Host

    Write-Host "  Enter your Service Password: " -ForegroundColor Yellow -NoNewline
    $password = Read-Host

    if ([string]::IsNullOrWhiteSpace($username) -or [string]::IsNullOrWhiteSpace($password)) {
        Write-Error-Custom "Username and password cannot be empty!"
        return $null
    }

    return @{
        Username = $username.Trim()
        Password = $password.Trim()
    }
}

function Get-ServerCountry {
    Write-Banner
    Write-Host "  STEP 3: SERVER LOCATION" -ForegroundColor Magenta
    Write-Host "  -----------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Pick the closest country to you for best speeds!" -ForegroundColor Yellow
    Write-Host "  (NordVPN's no-logs policy protects you on ANY server)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Popular choices:" -ForegroundColor White
    Write-Host "    1. United States" -ForegroundColor Gray
    Write-Host "    2. United Kingdom" -ForegroundColor Gray
    Write-Host "    3. Canada" -ForegroundColor Gray
    Write-Host "    4. Netherlands" -ForegroundColor Gray
    Write-Host "    5. Custom" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Select (1-5) [default: 1]: " -ForegroundColor Yellow -NoNewline
    $choice = Read-Host

    switch ($choice) {
        "2" { return "United Kingdom" }
        "3" { return "Canada" }
        "4" { return "Netherlands" }
        "5" {
            Write-Host "  Enter country name (capitalize first letter): " -ForegroundColor Yellow -NoNewline
            return Read-Host
        }
        default { return "United States" }
    }
}

function Get-Timezone {
    Write-Banner
    Write-Host "  STEP 4: TIMEZONE" -ForegroundColor Magenta
    Write-Host "  ----------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Common timezones:" -ForegroundColor White
    Write-Host "    1. America/Los_Angeles (Pacific)" -ForegroundColor Gray
    Write-Host "    2. America/Denver (Mountain)" -ForegroundColor Gray
    Write-Host "    3. America/Chicago (Central)" -ForegroundColor Gray
    Write-Host "    4. America/New_York (Eastern)" -ForegroundColor Gray
    Write-Host "    5. Europe/London" -ForegroundColor Gray
    Write-Host "    6. Europe/Berlin" -ForegroundColor Gray
    Write-Host "    7. Custom" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Select (1-7) [default: 1]: " -ForegroundColor Yellow -NoNewline
    $choice = Read-Host

    switch ($choice) {
        "2" { return "America/Denver" }
        "3" { return "America/Chicago" }
        "4" { return "America/New_York" }
        "5" { return "Europe/London" }
        "6" { return "Europe/Berlin" }
        "7" {
            Write-Host "  Enter timezone (e.g., Australia/Sydney): " -ForegroundColor Yellow -NoNewline
            return Read-Host
        }
        default { return "America/Los_Angeles" }
    }
}

# --- File Generation ---
function New-EnvFile {
    param(
        [string]$Path,
        [hashtable]$VPN,
        [hashtable]$Credentials,
        [string]$Country,
        [string]$Timezone
    )

    $content = @"
# ==========================================
# TOM SPARK'S PRIVACY BOX CONFIG
# Created by Tom Spark | youtube.com/@TomSparkReviews
#
# VPN: $($VPN.Name) ($($VPN.Affiliate))
# ==========================================

# --- VPN PROVIDER ---
VPN_PROVIDER=$($VPN.Provider)

# --- VPN CREDENTIALS ---
# Service Credentials from: $($VPN.URL)
VPN_USER="$($Credentials.Username)"
VPN_PASSWORD="$($Credentials.Password)"

# --- SERVER LOCATION ---
SERVER_COUNTRIES=$Country

# --- SYSTEM SETTINGS ---
TZ=$Timezone
ROOT_DIR=.
"@

    $content | Out-File -FilePath "$Path\.env" -Encoding UTF8 -NoNewline
}

function New-DockerComposeFile {
    param([string]$Path)

    $content = @'
# ==========================================
# TOM SPARK'S PRIVACY BOX
# Created by Tom Spark | youtube.com/@TomSparkReviews
#
# VPN Options:
#   NordVPN:   nordvpn.tomspark.tech   (4 extra months FREE!)
#   ProtonVPN: protonvpn.tomspark.tech (3 months FREE!)
#   Surfshark: surfshark.tomspark.tech (3 extra months FREE!)
# ==========================================

services:
  gluetun:
    image: qmcgaw/gluetun
    container_name: gluetun
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    ports:
      - 8080:8080   # qBittorrent
      - 8181:9696   # Prowlarr (Safe Port - avoids Windows conflicts)
      - 8989:8989   # Sonarr
      - 7878:7878   # Radarr
    environment:
      - VPN_SERVICE_PROVIDER=${VPN_PROVIDER}
      - VPN_TYPE=openvpn
      - OPENVPN_USER=${VPN_USER}
      - OPENVPN_PASSWORD=${VPN_PASSWORD}
      - SERVER_COUNTRIES=${SERVER_COUNTRIES}
      - FIREWALL_OUTBOUND_SUBNETS=192.168.0.0/16,10.0.0.0/8,172.16.0.0/12
    volumes:
      - ${ROOT_DIR}/config/gluetun:/gluetun
    restart: always

  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=${TZ}
      - WEBUI_PORT=8080
    volumes:
      - ${ROOT_DIR}/config/qbittorrent:/config
      - ${ROOT_DIR}/media/downloads:/data/downloads
    network_mode: service:gluetun
    depends_on:
      - gluetun
    restart: always

  prowlarr:
    image: lscr.io/linuxserver/prowlarr:latest
    container_name: prowlarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=${TZ}
    volumes:
      - ${ROOT_DIR}/config/prowlarr:/config
    network_mode: service:gluetun
    depends_on:
      - gluetun
    restart: always

  sonarr:
    image: lscr.io/linuxserver/sonarr:latest
    container_name: sonarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=${TZ}
    volumes:
      - ${ROOT_DIR}/config/sonarr:/config
      - ${ROOT_DIR}/media:/data/media
      - ${ROOT_DIR}/media/downloads:/data/downloads
    network_mode: service:gluetun
    depends_on:
      - gluetun
    restart: always

  radarr:
    image: lscr.io/linuxserver/radarr:latest
    container_name: radarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=${TZ}
    volumes:
      - ${ROOT_DIR}/config/radarr:/config
      - ${ROOT_DIR}/media:/data/media
      - ${ROOT_DIR}/media/downloads:/data/downloads
    network_mode: service:gluetun
    depends_on:
      - gluetun
    restart: always

  # --- Media Server (accessible on local network) ---
  jellyfin:
    image: lscr.io/linuxserver/jellyfin:latest
    container_name: jellyfin
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=${TZ}
    ports:
      - 8096:8096   # Jellyfin Web UI
    volumes:
      - ${ROOT_DIR}/config/jellyfin:/config
      - ${ROOT_DIR}/media/tv:/data/tvshows
      - ${ROOT_DIR}/media/movies:/data/movies
    restart: always
'@

    $content | Out-File -FilePath "$Path\docker-compose.yml" -Encoding UTF8 -NoNewline
}

# --- Docker Operations ---
function Start-PrivacyBox {
    param([string]$Path)

    Write-Banner
    Write-Host "  LAUNCHING PRIVACY BOX" -ForegroundColor Magenta
    Write-Host "  ---------------------" -ForegroundColor DarkGray
    Write-Host ""

    Push-Location $Path

    Write-Step "1" "Pulling Docker images (this may take a few minutes on first run)..."
    Write-Host ""

    docker compose pull 2>&1 | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }

    Write-Host ""
    Write-Step "2" "Starting containers..."
    Write-Host ""

    docker compose up -d 2>&1 | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }

    Pop-Location

    Write-Host ""
    Write-Step "3" "Waiting for VPN to connect..."

    $maxAttempts = 30
    $attempt = 0
    $connected = $false

    while ($attempt -lt $maxAttempts -and -not $connected) {
        Start-Sleep -Seconds 2
        $attempt++

        $health = docker inspect --format='{{.State.Health.Status}}' gluetun 2>$null
        if ($health -eq "healthy") {
            $connected = $true
        }

        Write-Host "." -NoNewline -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host ""

    if ($connected) {
        # Get VPN IP
        $logs = docker logs gluetun 2>&1 | Select-String "Public IP address is"
        if ($logs) {
            $ip = $logs[-1] -replace '.*Public IP address is (\S+).*', '$1'
            Write-Success "VPN Connected! Your IP: $ip"
        } else {
            Write-Success "VPN Connected!"
        }
        return $true
    } else {
        Write-Error-Custom "VPN connection timed out. Checking logs..."
        Write-Host ""
        docker logs gluetun 2>&1 | Select-String "AUTH_FAILED|error|Error" | Select-Object -Last 5 | ForEach-Object {
            Write-Host "      $_" -ForegroundColor Red
        }
        return $false
    }
}

# --- Guided Setup ---
function Show-SetupGuide {
    # --- qBittorrent Setup ---
    Write-Banner
    Write-Host "  SETUP GUIDE: qBittorrent (Step 1 of 4)" -ForegroundColor Magenta
    Write-Host "  --------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Press ENTER to open qBittorrent in your browser..." -ForegroundColor Yellow
    Read-Host | Out-Null
    Start-Process "http://localhost:8080"
    Write-Host ""
    Write-Host "  Login:" -ForegroundColor Yellow
    Write-Host "    Username: " -ForegroundColor White -NoNewline
    Write-Host "admin" -ForegroundColor Cyan
    Write-Host "    Password: " -ForegroundColor White -NoNewline
    Write-Host "(check the command below)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  " -NoNewline
    Write-Host " IMPORTANT " -BackgroundColor DarkRed -ForegroundColor White
    Write-Host "  qBittorrent generates a random password on first run." -ForegroundColor White
    Write-Host ""
    Write-Host "  To find your password:" -ForegroundColor Yellow
    Write-Host "    1. Press " -ForegroundColor White -NoNewline
    Write-Host "Windows + R" -ForegroundColor Cyan -NoNewline
    Write-Host ", type " -ForegroundColor White -NoNewline
    Write-Host "cmd" -ForegroundColor Cyan -NoNewline
    Write-Host ", press Enter" -ForegroundColor White
    Write-Host "    2. In the black window, paste this command:" -ForegroundColor White
    Write-Host ""
    Write-Host "       docker logs qbittorrent 2>&1 | findstr password" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "    3. Press Enter - your password will appear" -ForegroundColor White
    Write-Host "    4. Copy the password and use it to log in above" -ForegroundColor White
    Write-Host ""
    Write-Host "  After logging in, change your password:" -ForegroundColor Yellow
    Write-Host "    Tools > Options > Web UI > Password" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  " -NoNewline
    Write-Host " VPN VERIFICATION " -BackgroundColor DarkGreen -ForegroundColor White
    Write-Host "  Go to: Tools > Options > Advanced" -ForegroundColor White
    Write-Host "  Look for 'Network Interface' - it should say: " -ForegroundColor White -NoNewline
    Write-Host "tun0" -ForegroundColor Green
    Write-Host "  This proves your traffic is going through the VPN tunnel!" -ForegroundColor Gray

    Press-Enter

    # --- Prowlarr Setup ---
    Write-Banner
    Write-Host "  SETUP GUIDE: Prowlarr (Step 2 of 4)" -ForegroundColor Magenta
    Write-Host "  -----------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Press ENTER to open Prowlarr in your browser..." -ForegroundColor Yellow
    Read-Host | Out-Null
    Start-Process "http://localhost:8181"
    Write-Host ""
    Write-Host "  " -NoNewline
    Write-Host " IMPORTANT " -BackgroundColor DarkRed -ForegroundColor White
    Write-Host ""
    Write-Host "  1. Create your admin account when prompted" -ForegroundColor White
    Write-Host ""
    Write-Host "  2. Add Indexers:" -ForegroundColor Yellow
    Write-Host "     - Click 'Indexers' in the sidebar" -ForegroundColor White
    Write-Host "     - Click '+ Add Indexer'" -ForegroundColor White
    Write-Host "     - " -ForegroundColor White -NoNewline
    Write-Host "CRITICAL: Change 'Language' filter from 'en-US' to 'Any'" -ForegroundColor Red
    Write-Host "       (Otherwise you'll only see ~6 indexers instead of 400+)" -ForegroundColor Gray
    Write-Host "     - Add: 1337x, TorrentGalaxy, or your preferred sites" -ForegroundColor White
    Write-Host ""
    Write-Host "  3. We'll connect Prowlarr to Sonarr/Radarr in the next steps" -ForegroundColor Gray

    Press-Enter

    # --- Sonarr Setup ---
    Write-Banner
    Write-Host "  SETUP GUIDE: Sonarr (Step 3 of 4)" -ForegroundColor Magenta
    Write-Host "  ---------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Press ENTER to open Sonarr in your browser..." -ForegroundColor Yellow
    Read-Host | Out-Null
    Start-Process "http://localhost:8989"
    Write-Host ""
    Write-Host "  1. Create your admin account when prompted" -ForegroundColor White
    Write-Host ""
    Write-Host "  2. Add Root Folder (where TV shows are saved):" -ForegroundColor Yellow
    Write-Host "     - Go to: Settings > Media Management" -ForegroundColor White
    Write-Host "     - Scroll down and click 'Add Root Folder'" -ForegroundColor White
    Write-Host "     - Enter path: " -ForegroundColor White -NoNewline
    Write-Host "/data/media/tv" -ForegroundColor Cyan
    Write-Host "     - Click 'OK'" -ForegroundColor White
    Write-Host ""
    Write-Host "  3. Add Download Client:" -ForegroundColor Yellow
    Write-Host "     - Go to: Settings > Download Clients" -ForegroundColor White
    Write-Host "     - Click '+' and select 'qBittorrent'" -ForegroundColor White
    Write-Host "     - Host: " -ForegroundColor White -NoNewline
    Write-Host "localhost" -ForegroundColor Cyan
    Write-Host "     - Port: " -ForegroundColor White -NoNewline
    Write-Host "8080" -ForegroundColor Cyan
    Write-Host "     - Username: " -ForegroundColor White -NoNewline
    Write-Host "admin" -ForegroundColor Cyan
    Write-Host "     - Password: " -ForegroundColor White -NoNewline
    Write-Host "(your qBittorrent password)" -ForegroundColor Cyan
    Write-Host "     - Click 'Test' then 'Save'" -ForegroundColor White
    Write-Host ""
    Write-Host "  4. Copy your API Key:" -ForegroundColor Yellow
    Write-Host "     - Go to: Settings > General" -ForegroundColor White
    Write-Host "     - Copy the 'API Key' (you'll need this for Prowlarr)" -ForegroundColor White

    Press-Enter

    # --- Radarr Setup ---
    Write-Banner
    Write-Host "  SETUP GUIDE: Radarr (Step 4 of 4)" -ForegroundColor Magenta
    Write-Host "  ---------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Press ENTER to open Radarr in your browser..." -ForegroundColor Yellow
    Read-Host | Out-Null
    Start-Process "http://localhost:7878"
    Write-Host ""
    Write-Host "  1. Create your admin account when prompted" -ForegroundColor White
    Write-Host ""
    Write-Host "  2. Add Root Folder (where movies are saved):" -ForegroundColor Yellow
    Write-Host "     - Go to: Settings > Media Management" -ForegroundColor White
    Write-Host "     - Scroll down and click 'Add Root Folder'" -ForegroundColor White
    Write-Host "     - Enter path: " -ForegroundColor White -NoNewline
    Write-Host "/data/media/movies" -ForegroundColor Cyan
    Write-Host "     - Click 'OK'" -ForegroundColor White
    Write-Host ""
    Write-Host "  3. Add Download Client (same as Sonarr):" -ForegroundColor Yellow
    Write-Host "     - Go to: Settings > Download Clients" -ForegroundColor White
    Write-Host "     - Click '+' and select 'qBittorrent'" -ForegroundColor White
    Write-Host "     - Host: " -ForegroundColor White -NoNewline
    Write-Host "localhost" -ForegroundColor Cyan
    Write-Host "     - Port: " -ForegroundColor White -NoNewline
    Write-Host "8080" -ForegroundColor Cyan
    Write-Host "     - Username/Password: same as before" -ForegroundColor White
    Write-Host "     - Click 'Test' then 'Save'" -ForegroundColor White
    Write-Host ""
    Write-Host "  4. Copy your API Key:" -ForegroundColor Yellow
    Write-Host "     - Go to: Settings > General" -ForegroundColor White
    Write-Host "     - Copy the 'API Key' (you'll need this for Prowlarr)" -ForegroundColor White

    Press-Enter

    # --- Connect Prowlarr ---
    Write-Banner
    Write-Host "  FINAL STEP: Connect Prowlarr to Apps" -ForegroundColor Magenta
    Write-Host "  ------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Press ENTER to open Prowlarr in your browser..." -ForegroundColor Yellow
    Read-Host | Out-Null
    Start-Process "http://localhost:8181"
    Write-Host ""
    Write-Host "  Go to: Settings > Apps" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Add Sonarr:" -ForegroundColor White
    Write-Host "    - Click '+' and select 'Sonarr'" -ForegroundColor Gray
    Write-Host "    - Prowlarr Server: " -ForegroundColor Gray -NoNewline
    Write-Host "http://localhost:9696" -ForegroundColor Cyan
    Write-Host "    - Sonarr Server: " -ForegroundColor Gray -NoNewline
    Write-Host "http://localhost:8989" -ForegroundColor Cyan
    Write-Host "    - API Key: " -ForegroundColor Gray -NoNewline
    Write-Host "(paste the Sonarr API key you copied)" -ForegroundColor Cyan
    Write-Host "    - Click 'Test' then 'Save'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Add Radarr:" -ForegroundColor White
    Write-Host "    - Click '+' and select 'Radarr'" -ForegroundColor Gray
    Write-Host "    - Prowlarr Server: " -ForegroundColor Gray -NoNewline
    Write-Host "http://localhost:9696" -ForegroundColor Cyan
    Write-Host "    - Radarr Server: " -ForegroundColor Gray -NoNewline
    Write-Host "http://localhost:7878" -ForegroundColor Cyan
    Write-Host "    - API Key: " -ForegroundColor Gray -NoNewline
    Write-Host "(paste the Radarr API key you copied)" -ForegroundColor Cyan
    Write-Host "    - Click 'Test' then 'Save'" -ForegroundColor Gray

    Press-Enter

    # --- Jellyfin Setup ---
    Write-Banner
    Write-Host "  SETUP GUIDE: Jellyfin (Media Server)" -ForegroundColor Magenta
    Write-Host "  ------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  " -NoNewline
    Write-Host " JELLYFIN IS ALREADY INSTALLED! " -BackgroundColor DarkGreen -ForegroundColor White
    Write-Host ""
    Write-Host "  Jellyfin is included in your Privacy Box. Watch your media on any device!" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Press ENTER to open Jellyfin in your browser..." -ForegroundColor Yellow
    Read-Host | Out-Null
    Start-Process "http://localhost:8096"
    Write-Host ""
    Write-Host "  " -NoNewline
    Write-Host " STEP 1: Initial Setup " -BackgroundColor DarkBlue -ForegroundColor White
    Write-Host ""
    Write-Host "  1. Select your language and click Next" -ForegroundColor White
    Write-Host "  2. Create your admin username and password" -ForegroundColor White
    Write-Host "  3. Click 'Add Media Library' and add:" -ForegroundColor White
    Write-Host ""
    Write-Host "     For Movies:" -ForegroundColor Yellow
    Write-Host "       - Content type: Movies" -ForegroundColor Gray
    Write-Host "       - Click '+' next to Folders" -ForegroundColor Gray
    Write-Host "       - Enter: " -ForegroundColor Gray -NoNewline
    Write-Host "/data/movies" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "     For TV Shows:" -ForegroundColor Yellow
    Write-Host "       - Content type: Shows" -ForegroundColor Gray
    Write-Host "       - Click '+' next to Folders" -ForegroundColor Gray
    Write-Host "       - Enter: " -ForegroundColor Gray -NoNewline
    Write-Host "/data/tvshows" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  4. Finish the setup wizard" -ForegroundColor White
    Write-Host ""
    Write-Host "  " -NoNewline
    Write-Host " STEP 2: Watch on Other Devices " -BackgroundColor DarkBlue -ForegroundColor White
    Write-Host ""
    Write-Host "  Same Network (Home WiFi):" -ForegroundColor Yellow
    Write-Host "    1. Find this PC's IP: Open CMD and type 'ipconfig'" -ForegroundColor White
    Write-Host "       Look for 'IPv4 Address' (e.g., 192.168.1.100)" -ForegroundColor Gray
    Write-Host "    2. On your TV/phone/tablet, download the Jellyfin app" -ForegroundColor White
    Write-Host "    3. Enter server address: " -ForegroundColor White -NoNewline
    Write-Host "http://YOUR-PC-IP:8096" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  " -NoNewline
    Write-Host " CAN'T CONNECT FROM OTHER DEVICES? " -BackgroundColor DarkRed -ForegroundColor White
    Write-Host ""
    Write-Host "  Windows Firewall may be blocking connections:" -ForegroundColor Yellow
    Write-Host "    1. Open Windows Defender Firewall" -ForegroundColor White
    Write-Host "    2. Click 'Allow an app through firewall'" -ForegroundColor White
    Write-Host "    3. Click 'Change settings' then 'Allow another app'" -ForegroundColor White
    Write-Host "    4. Add: " -ForegroundColor White -NoNewline
    Write-Host "C:\Windows\System32\cmd.exe" -ForegroundColor Cyan -NoNewline
    Write-Host " (Docker handles the rest)" -ForegroundColor Gray
    Write-Host "    5. Check BOTH 'Private' and 'Public' boxes" -ForegroundColor White
    Write-Host ""
    Write-Host "  Or allow the port directly (PowerShell as Admin):" -ForegroundColor Gray
    Write-Host "    Jellyfin: " -ForegroundColor Gray -NoNewline
    Write-Host "netsh advfirewall firewall add rule name=`"Jellyfin`" dir=in action=allow protocol=tcp localport=8096" -ForegroundColor DarkGray
    Write-Host "    Emby:     " -ForegroundColor Gray -NoNewline
    Write-Host "netsh advfirewall firewall add rule name=`"Emby`" dir=in action=allow protocol=tcp localport=8920" -ForegroundColor DarkGray

    Press-Enter

    # --- Remote Access Setup (Optional) ---
    Write-Banner
    Write-Host "  OPTIONAL: Watch Your Media From Anywhere" -ForegroundColor Magenta
    Write-Host "  -----------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Want to access your media outside your home (hotel, work, etc.)?" -ForegroundColor White
    Write-Host "  Use a secure mesh network - NO port forwarding needed!" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  " -NoNewline
    Write-Host " OPTION 1: NordVPN Meshnet (You already have NordVPN!) " -BackgroundColor DarkGreen -ForegroundColor White
    Write-Host ""
    Write-Host "  On this PC:" -ForegroundColor Yellow
    Write-Host "    1. Install NordVPN app: " -ForegroundColor White -NoNewline
    Write-Host "https://nordvpn.com/download/" -ForegroundColor Cyan
    Write-Host "    2. Sign in and go to 'Meshnet' in the left sidebar" -ForegroundColor White
    Write-Host "    3. Turn ON Meshnet" -ForegroundColor White
    Write-Host "    4. Note your device's Meshnet name (e.g., my-pc.nord)" -ForegroundColor White
    Write-Host ""
    Write-Host "  On your phone/laptop (when away from home):" -ForegroundColor Yellow
    Write-Host "    1. Install NordVPN app and sign in with same account" -ForegroundColor White
    Write-Host "    2. Go to Meshnet and turn it ON" -ForegroundColor White
    Write-Host "    3. Your PC will appear under 'Your devices'" -ForegroundColor White
    Write-Host "    4. Open Jellyfin/Emby app and connect to:" -ForegroundColor White
    Write-Host "       " -ForegroundColor White -NoNewline
    Write-Host "http://your-pc-name.nord:8096" -ForegroundColor Cyan -NoNewline
    Write-Host " (Jellyfin)" -ForegroundColor Gray
    Write-Host "       " -ForegroundColor White -NoNewline
    Write-Host "http://your-pc-name.nord:8920" -ForegroundColor Cyan -NoNewline
    Write-Host " (Emby)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  " -NoNewline
    Write-Host " OPTION 2: Tailscale (Free alternative) " -BackgroundColor DarkBlue -ForegroundColor White
    Write-Host ""
    Write-Host "  On this PC:" -ForegroundColor Yellow
    Write-Host "    1. Download Tailscale: " -ForegroundColor White -NoNewline
    Write-Host "https://tailscale.com/download" -ForegroundColor Cyan
    Write-Host "    2. Install and sign in (Google/Microsoft/etc.)" -ForegroundColor White
    Write-Host "    3. Note your Tailscale IP (starts with 100.x.x.x)" -ForegroundColor White
    Write-Host ""
    Write-Host "  On your phone/laptop:" -ForegroundColor Yellow
    Write-Host "    1. Install Tailscale app and sign in with same account" -ForegroundColor White
    Write-Host "    2. Open Jellyfin/Emby app and connect to:" -ForegroundColor White
    Write-Host "       " -ForegroundColor White -NoNewline
    Write-Host "http://100.x.x.x:8096" -ForegroundColor Cyan -NoNewline
    Write-Host " (use your actual Tailscale IP)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  " -NoNewline
    Write-Host " WHY THIS IS SAFE " -BackgroundColor DarkMagenta -ForegroundColor White
    Write-Host ""
    Write-Host "  Both options create an encrypted tunnel directly between your devices." -ForegroundColor Gray
    Write-Host "  Nothing is exposed to the internet - no hackers can find your server!" -ForegroundColor Gray
    Write-Host "  This does NOT interfere with your torrent VPN (that runs in Docker)." -ForegroundColor Gray

    Press-Enter

    # --- Complete ---
    Write-Banner
    Write-Host ""
    Write-Host "  =============================================" -ForegroundColor Green
    Write-Host "       PRIVACY BOX SETUP COMPLETE!" -ForegroundColor White
    Write-Host "  =============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Your Services:" -ForegroundColor Yellow
    Write-Host "    qBittorrent:  http://localhost:8080" -ForegroundColor White
    Write-Host "    Prowlarr:     http://localhost:8181" -ForegroundColor White
    Write-Host "    Sonarr:       http://localhost:8989" -ForegroundColor White
    Write-Host "    Radarr:       http://localhost:7878" -ForegroundColor White
    Write-Host "    Jellyfin:     http://localhost:8096" -ForegroundColor Cyan -NoNewline
    Write-Host " (Media Server)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Your media folder:" -ForegroundColor Yellow
    Write-Host "    $env:USERPROFILE\Desktop\PrivacyServer\media\" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Your traffic is now secured through the VPN!" -ForegroundColor Green
    Write-Host ""
    Write-Host "  =============================================" -ForegroundColor DarkGray
    Write-Host "  IS IT RUNNING?" -ForegroundColor Yellow
    Write-Host "  =============================================" -ForegroundColor DarkGray
    Write-Host "  Your Privacy Box is currently " -ForegroundColor White -NoNewline
    Write-Host "RUNNING" -ForegroundColor Green -NoNewline
    Write-Host "!" -ForegroundColor White
    Write-Host "  It will keep running in the background." -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Useful Commands (run from PrivacyServer folder):" -ForegroundColor Yellow
    Write-Host "    Start:   docker compose up -d" -ForegroundColor Gray
    Write-Host "    Stop:    docker compose down" -ForegroundColor Gray
    Write-Host "    Restart: docker compose restart" -ForegroundColor Gray
    Write-Host "    Status:  docker ps" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  =============================================" -ForegroundColor Cyan
    Write-Host "  Created by TOM SPARK" -ForegroundColor Yellow
    Write-Host "  Subscribe: youtube.com/@TomSparkReviews" -ForegroundColor White
    Write-Host ""
    Write-Host "  VPN Deals:" -ForegroundColor White
    Write-Host "    NordVPN:   nordvpn.tomspark.tech   " -ForegroundColor Green -NoNewline
    Write-Host "(4 extra months FREE!)" -ForegroundColor Green
    Write-Host "    ProtonVPN: protonvpn.tomspark.tech " -ForegroundColor Cyan -NoNewline
    Write-Host "(3 months FREE!)" -ForegroundColor Cyan
    Write-Host "    Surfshark: surfshark.tomspark.tech " -ForegroundColor Yellow -NoNewline
    Write-Host "(3 extra months FREE!)" -ForegroundColor Yellow
    Write-Host "  =============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Questions? Join the Discord!" -ForegroundColor Yellow
    Write-Host "  https://discord.gg/uPdRcKxEVS" -ForegroundColor Cyan
    Write-Host ""
}

# --- Main Execution ---
function Main {
    Write-Banner

    # Pre-flight checks
    if (-not $SkipDockerCheck) {
        if (-not (Test-DockerInstalled)) {
            Press-Enter
            exit 1
        }

        if (-not (Test-DockerRunning)) {
            Press-Enter
            exit 1
        }
    }

    Write-Success "Pre-flight checks passed!"
    Press-Enter

    # Collect configuration
    $vpn = Get-VPNProvider
    Write-Host ""
    Write-Success "Selected: $($vpn.Name)"
    Press-Enter

    $credentials = Get-VPNCredentials -VPN $vpn
    if (-not $credentials) {
        exit 1
    }

    $country = Get-ServerCountry
    $timezone = Get-Timezone

    # Confirmation
    Write-Banner
    Write-Host "  CONFIGURATION SUMMARY" -ForegroundColor Magenta
    Write-Host "  ---------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Install Path:    $InstallPath" -ForegroundColor White
    Write-Host "  VPN Provider:    $($vpn.Name)" -ForegroundColor White
    Write-Host "  VPN Username:    $($credentials.Username)" -ForegroundColor White
    Write-Host "  VPN Password:    $("*" * $credentials.Password.Length)" -ForegroundColor White
    Write-Host "  Server Country:  $country" -ForegroundColor White
    Write-Host "  Timezone:        $timezone" -ForegroundColor White
    Write-Host ""

    if (-not (Ask-YesNo "Proceed with installation?")) {
        Write-Host ""
        Write-Info "Installation cancelled."
        exit 0
    }

    # Create directory structure
    Write-Banner
    Write-Host "  CREATING FILES" -ForegroundColor Magenta
    Write-Host "  --------------" -ForegroundColor DarkGray
    Write-Host ""

    Write-Step "1" "Creating directory: $InstallPath"
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    New-Item -ItemType Directory -Path "$InstallPath\config" -Force | Out-Null
    New-Item -ItemType Directory -Path "$InstallPath\media\downloads" -Force | Out-Null
    Write-Success "Directories created"

    Write-Step "2" "Generating .env file..."
    New-EnvFile -Path $InstallPath -VPN $vpn -Credentials $credentials -Country $country -Timezone $timezone
    Write-Success ".env file created"

    Write-Step "3" "Generating docker-compose.yml..."
    New-DockerComposeFile -Path $InstallPath
    Write-Success "docker-compose.yml created"

    Press-Enter

    # Launch
    $success = Start-PrivacyBox -Path $InstallPath

    if ($success) {
        Press-Enter
        Show-SetupGuide
    } else {
        Write-Host ""
        Write-Error-Custom "Setup failed. Please check your VPN credentials."
        Write-Host ""
        Write-Host "  Common fixes:" -ForegroundColor Yellow
        Write-Host "    1. Make sure you're using 'Service Credentials' from $($vpn.Name)" -ForegroundColor White
        Write-Host "    2. NOT your email/password login" -ForegroundColor White
        Write-Host "    3. Get credentials from: " -ForegroundColor White -NoNewline
        Write-Host $vpn.URL -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  To retry, run this script again." -ForegroundColor Gray
    }
}

# Run
Main
