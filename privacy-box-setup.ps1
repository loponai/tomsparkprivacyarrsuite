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
$script:BeginnerMode = $false
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

# --- Beginner Mode ---
function Show-BeginnerTip {
    param(
        [string]$Title,
        [string]$Body
    )

    if (-not $script:BeginnerMode) {
        return
    }

    Write-Host ""
    Write-Host "  +----------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "  |  " -ForegroundColor Cyan -NoNewline
    Write-Host "[TIP] $Title" -ForegroundColor White
    Write-Host "  +----------------------------------------------------+" -ForegroundColor Cyan
    $Body -split "`n" | ForEach-Object {
        Write-Host "  |  " -ForegroundColor Cyan -NoNewline
        Write-Host $_.Trim() -ForegroundColor Gray
    }
    Write-Host "  +----------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Press ENTER to continue..." -ForegroundColor DarkGray
    Read-Host | Out-Null
}

function Get-ExperienceLevel {
    Write-Banner
    Write-Host "  EXPERIENCE LEVEL" -ForegroundColor Magenta
    Write-Host "  ----------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  How familiar are you with the ARR suite?" -ForegroundColor White
    Write-Host ""
    Write-Host "    1. I'm brand new to ARR" -ForegroundColor Green -NoNewline
    Write-Host "  (show me extra explanations)" -ForegroundColor Gray
    Write-Host "    2. I'm familiar with ARR" -ForegroundColor Cyan -NoNewline
    Write-Host " (skip the intro tips)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Select (1-2) [default: 1]: " -ForegroundColor Yellow -NoNewline
    $choice = Read-Host

    switch ($choice) {
        "2" {
            $script:BeginnerMode = $false
            Write-Success "Experienced mode — skipping beginner tips."
        }
        default {
            $script:BeginnerMode = $true
            Write-Success "Beginner mode — extra tips will be shown throughout setup."
        }
    }
}

function Show-ArrOverview {
    if (-not $script:BeginnerMode) {
        return
    }

    Write-Banner
    Write-Host "  WHAT IS THE ARR SUITE?" -ForegroundColor Magenta
    Write-Host "  ----------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  The ARR suite is a collection of apps that work together" -ForegroundColor White
    Write-Host "  to automatically find, download, and organize media:" -ForegroundColor White
    Write-Host ""
    Write-Host "  +---------------+--------------------------------------------+" -ForegroundColor Cyan
    Write-Host "  | " -ForegroundColor Cyan -NoNewline
    Write-Host "Service" -ForegroundColor Yellow -NoNewline
    Write-Host "       | " -ForegroundColor Cyan -NoNewline
    Write-Host "What it does" -ForegroundColor White -NoNewline
    Write-Host "                              |" -ForegroundColor Cyan
    Write-Host "  +---------------+--------------------------------------------+" -ForegroundColor Cyan
    Write-Host "  | " -ForegroundColor Cyan -NoNewline
    Write-Host "qBittorrent" -ForegroundColor Green -NoNewline
    Write-Host "   | " -ForegroundColor Cyan -NoNewline
    Write-Host "Downloads files (through VPN for safety)" -ForegroundColor Gray -NoNewline
    Write-Host "  |" -ForegroundColor Cyan
    Write-Host "  | " -ForegroundColor Cyan -NoNewline
    Write-Host "Prowlarr" -ForegroundColor Green -NoNewline
    Write-Host "      | " -ForegroundColor Cyan -NoNewline
    Write-Host "Searches torrent sites for content" -ForegroundColor Gray -NoNewline
    Write-Host "       |" -ForegroundColor Cyan
    Write-Host "  | " -ForegroundColor Cyan -NoNewline
    Write-Host "Sonarr" -ForegroundColor Green -NoNewline
    Write-Host "        | " -ForegroundColor Cyan -NoNewline
    Write-Host "Finds & organizes TV shows automatically" -ForegroundColor Gray -NoNewline
    Write-Host " |" -ForegroundColor Cyan
    Write-Host "  | " -ForegroundColor Cyan -NoNewline
    Write-Host "Radarr" -ForegroundColor Green -NoNewline
    Write-Host "        | " -ForegroundColor Cyan -NoNewline
    Write-Host "Finds & organizes movies automatically" -ForegroundColor Gray -NoNewline
    Write-Host "   |" -ForegroundColor Cyan
    Write-Host "  | " -ForegroundColor Cyan -NoNewline
    Write-Host "Jellyfin" -ForegroundColor Green -NoNewline
    Write-Host "      | " -ForegroundColor Cyan -NoNewline
    Write-Host "Streams your media (like personal Netflix)" -ForegroundColor Gray -NoNewline
    Write-Host "|" -ForegroundColor Cyan
    Write-Host "  +---------------+--------------------------------------------+" -ForegroundColor Cyan
    Write-Host "  | " -ForegroundColor Cyan -NoNewline
    Write-Host "Optional:" -ForegroundColor Yellow -NoNewline
    Write-Host "      | " -ForegroundColor Cyan -NoNewline
    Write-Host "                                            " -ForegroundColor Gray -NoNewline
    Write-Host "|" -ForegroundColor Cyan
    Write-Host "  | " -ForegroundColor Cyan -NoNewline
    Write-Host "SABnzbd" -ForegroundColor Green -NoNewline
    Write-Host "       | " -ForegroundColor Cyan -NoNewline
    Write-Host "Downloads from Usenet (alternative to torrents)" -ForegroundColor Gray -NoNewline
    Write-Host "|" -ForegroundColor Cyan
    Write-Host "  | " -ForegroundColor Cyan -NoNewline
    Write-Host "Lidarr" -ForegroundColor Green -NoNewline
    Write-Host "        | " -ForegroundColor Cyan -NoNewline
    Write-Host "Finds & organizes music automatically" -ForegroundColor Gray -NoNewline
    Write-Host "   |" -ForegroundColor Cyan
    Write-Host "  +---------------+--------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  How they connect:" -ForegroundColor White
    Write-Host ""
    Write-Host "  You search in " -ForegroundColor Gray -NoNewline
    Write-Host "Sonarr/Radarr" -ForegroundColor Green -NoNewline
    Write-Host " -> " -ForegroundColor Gray -NoNewline
    Write-Host "Prowlarr" -ForegroundColor Green -NoNewline
    Write-Host " finds it -> " -ForegroundColor Gray -NoNewline
    Write-Host "qBittorrent" -ForegroundColor Green -NoNewline
    Write-Host " downloads it" -ForegroundColor Gray
    Write-Host "  -> " -ForegroundColor Gray -NoNewline
    Write-Host "Sonarr/Radarr" -ForegroundColor Green -NoNewline
    Write-Host " organizes it -> " -ForegroundColor Gray -NoNewline
    Write-Host "Jellyfin" -ForegroundColor Green -NoNewline
    Write-Host " streams it to your devices" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  All torrent traffic is routed through your VPN for privacy." -ForegroundColor Yellow

    Press-Enter
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
function Get-OtherVPNProvider {
    Write-Banner
    Write-Host "  OTHER VPN PROVIDERS" -ForegroundColor Magenta
    Write-Host "  -------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Select your VPN provider:" -ForegroundColor White
    Write-Host ""
    Write-Host "     1. Mullvad" -ForegroundColor White
    Write-Host "     2. Private Internet Access (PIA)" -ForegroundColor White
    Write-Host "     3. Windscribe" -ForegroundColor White
    Write-Host "     4. CyberGhost" -ForegroundColor White
    Write-Host "     5. IPVanish" -ForegroundColor White
    Write-Host "     6. AirVPN" -ForegroundColor White
    Write-Host "     7. Custom (any Gluetun-supported provider)" -ForegroundColor White
    Write-Host ""
    Write-Host "  Select (1-7) [default: 1]: " -ForegroundColor Yellow -NoNewline
    $otherChoice = Read-Host

    switch ($otherChoice) {
        "2" {
            return @{
                Provider = "private internet access"
                Name = "Private Internet Access"
                SupportsWireGuard = $true
            }
        }
        "3" {
            return @{
                Provider = "windscribe"
                Name = "Windscribe"
                SupportsWireGuard = $true
            }
        }
        "4" {
            return @{
                Provider = "cyberghost"
                Name = "CyberGhost"
                SupportsWireGuard = $true
            }
        }
        "5" {
            return @{
                Provider = "ipvanish"
                Name = "IPVanish"
                SupportsWireGuard = $false
                Protocol = "openvpn"
            }
        }
        "6" {
            return @{
                Provider = "airvpn"
                Name = "AirVPN"
                SupportsWireGuard = $true
            }
        }
        "7" {
            Write-Host ""
            Write-Host "  Enter the Gluetun provider name exactly as listed at:" -ForegroundColor White
            Write-Host "  https://github.com/qdm12/gluetun-wiki/tree/main/setup/providers" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "  Provider name: " -ForegroundColor Yellow -NoNewline
            $providerName = Read-Host
            Write-Host ""
            Write-Host "  Does this provider support WireGuard? (Y/N) [default: N]: " -ForegroundColor Yellow -NoNewline
            $wgResponse = Read-Host
            $supportsWg = $wgResponse -match "^[Yy]"
            $result = @{
                Provider = $providerName
                Name = $providerName
                SupportsWireGuard = $supportsWg
            }
            if (-not $supportsWg) {
                $result.Protocol = "openvpn"
            }
            return $result
        }
        default {
            return @{
                Provider = "mullvad"
                Name = "Mullvad"
                SupportsWireGuard = $true
            }
        }
    }
}

function Get-VPNProvider {
    Write-Banner
    Write-Host "  STEP 1: CHOOSE YOUR VPN" -ForegroundColor Magenta
    Write-Host "  -----------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  RECOMMENDED " -ForegroundColor White -NoNewline
    Write-Host "(Tested 10+ years for speed & security):" -ForegroundColor Gray
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
    Write-Host "  OTHER SUPPORTED VPNs:" -ForegroundColor White
    Write-Host ""
    Write-Host "    4. Other VPN provider" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Select (1-4) [default: 1]: " -ForegroundColor Yellow -NoNewline
    $choice = Read-Host

    switch ($choice) {
        "2" {
            return @{
                Provider = "protonvpn"
                Name = "ProtonVPN"
                Affiliate = "https://protonvpn.tomspark.tech/"
                Bonus = "3 months FREE"
                SupportsWireGuard = $true
            }
        }
        "3" {
            return @{
                Provider = "surfshark"
                Name = "Surfshark"
                Affiliate = "https://surfshark.tomspark.tech/"
                Bonus = "3 extra months FREE"
                SupportsWireGuard = $true
            }
        }
        "4" {
            return Get-OtherVPNProvider
        }
        default {
            return @{
                Provider = "nordvpn"
                Name = "NordVPN"
                URL = "https://my.nordaccount.com/dashboard/nordvpn/manual-configuration/"
                Affiliate = "https://nordvpn.tomspark.tech/"
                Bonus = "4 extra months FREE"
                SupportsWireGuard = $false
                Protocol = "openvpn"
            }
        }
    }
}

# --- VPN Protocol Selection (ProtonVPN/Surfshark only) ---
function Get-VPNProtocol {
    param([hashtable]$VPN)

    if (-not $VPN.SupportsWireGuard) {
        return @{
            Protocol = "openvpn"
            URL = $VPN.URL
        }
    }

    Write-Banner
    Write-Host "  STEP 1b: CHOOSE VPN PROTOCOL" -ForegroundColor Magenta
    Write-Host "  ----------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Which protocol would you like to use?" -ForegroundColor White
    Write-Host ""
    Write-Host "    1. OpenVPN" -ForegroundColor Green -NoNewline
    Write-Host "     - Traditional, widely compatible" -ForegroundColor Gray
    Write-Host "    2. WireGuard" -ForegroundColor Cyan -NoNewline
    Write-Host "   - Faster, more modern (Recommended)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Select (1-2) [default: 1]: " -ForegroundColor Yellow -NoNewline
    $choice = Read-Host

    switch ($choice) {
        "2" {
            $url = $null
            switch ($VPN.Provider) {
                "protonvpn" { $url = "https://account.proton.me/u/0/vpn/WireGuard" }
                "surfshark" { $url = "https://my.surfshark.com/vpn/manual-setup/main/wireguard" }
            }
            $result = @{ Protocol = "wireguard" }
            if ($url) { $result.URL = $url }
            return $result
        }
        default {
            $url = $null
            switch ($VPN.Provider) {
                "protonvpn" { $url = "https://account.proton.me/u/0/vpn/OpenVpnIKEv2" }
                "surfshark" { $url = "https://my.surfshark.com/vpn/manual-setup/main/openvpn" }
            }
            $result = @{ Protocol = "openvpn" }
            if ($url) { $result.URL = $url }
            return $result
        }
    }
}

# --- Credential Collection ---
function Get-VPNCredentials {
    param(
        [hashtable]$VPN,
        [hashtable]$ProtocolInfo
    )

    Write-Banner

    if ($ProtocolInfo.Protocol -eq "wireguard") {
        Write-Host "  STEP 2: WIREGUARD CREDENTIALS" -ForegroundColor Magenta
        Write-Host "  -----------------------------" -ForegroundColor DarkGray
        Write-Host ""
        Write-Warning-Custom "You need your WireGuard configuration from $($VPN.Name)"
        Write-Host ""
        Write-Host "  How to get them:" -ForegroundColor White
        if ($ProtocolInfo.URL) {
            Write-Host "  1. Go to: " -ForegroundColor Gray -NoNewline
            Write-Host $ProtocolInfo.URL -ForegroundColor Cyan
        } else {
            Write-Host "  1. Log in to your " -ForegroundColor Gray -NoNewline
            Write-Host $VPN.Name -ForegroundColor White -NoNewline
            Write-Host " account" -ForegroundColor Gray
            Write-Host "     Find the manual/service credentials or WireGuard config page" -ForegroundColor Gray
        }
        Write-Host "  2. Generate a new WireGuard configuration" -ForegroundColor Gray
        Write-Host "  3. You'll need the " -ForegroundColor Gray -NoNewline
        Write-Host "Private Key" -ForegroundColor White -NoNewline
        Write-Host " and " -ForegroundColor Gray -NoNewline
        Write-Host "Address" -ForegroundColor White -NoNewline
        Write-Host " (IP)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  Example values:" -ForegroundColor White
        Write-Host "    Private Key: " -ForegroundColor Gray -NoNewline
        Write-Host "yAnz5TF+lXXJte14tji3zlMNq+hd2rYUIgJBgB3fBmk=" -ForegroundColor Cyan
        Write-Host "    Address:     " -ForegroundColor Gray -NoNewline
        Write-Host "10.2.0.2/32" -ForegroundColor Cyan
        Write-Host ""

        if ($VPN.Affiliate) {
            Write-Host "  Don't have $($VPN.Name)? Get $($VPN.Bonus)!" -ForegroundColor Green
            Write-Host "  $($VPN.Affiliate)" -ForegroundColor Cyan
            Write-Host ""
        }

        if ($ProtocolInfo.URL) {
            if (Ask-YesNo "Open $($VPN.Name) WireGuard page in your browser now?") {
                Start-Process $ProtocolInfo.URL
                Write-Host ""
                Write-Info "Browser opened. Generate a config, then copy the Private Key and Address."
                Press-Enter
            }
        }

        Write-Host ""
        Write-Host "  Enter your WireGuard Private Key: " -ForegroundColor Yellow -NoNewline
        $privateKey = Read-Host

        Write-Host "  Enter your WireGuard Address (e.g., 10.2.0.2/32): " -ForegroundColor Yellow -NoNewline
        $address = Read-Host

        if ([string]::IsNullOrWhiteSpace($privateKey) -or [string]::IsNullOrWhiteSpace($address)) {
            Write-Error-Custom "Private Key and Address cannot be empty!"
            return $null
        }

        return @{
            Type = "wireguard"
            PrivateKey = $privateKey.Trim()
            Address = $address.Trim()
        }
    } else {
        Write-Host "  STEP 2: VPN CREDENTIALS" -ForegroundColor Magenta
        Write-Host "  -----------------------" -ForegroundColor DarkGray
        Write-Host ""
        Write-Warning-Custom "You need $($VPN.Name) 'Service Credentials' (NOT your email/password!)"
        Write-Host ""
        Write-Host "  How to get them:" -ForegroundColor White
        if ($ProtocolInfo.URL) {
            Write-Host "  1. Go to: " -ForegroundColor Gray -NoNewline
            Write-Host $ProtocolInfo.URL -ForegroundColor Cyan
        } else {
            Write-Host "  1. Log in to your " -ForegroundColor Gray -NoNewline
            Write-Host $VPN.Name -ForegroundColor White -NoNewline
            Write-Host " account" -ForegroundColor Gray
            Write-Host "     Find the manual/service credentials or OpenVPN setup page" -ForegroundColor Gray
        }
        Write-Host "  2. Look for 'Manual Setup' or 'OpenVPN' credentials" -ForegroundColor Gray
        Write-Host "  3. Copy the Username and Password shown there" -ForegroundColor Gray
        Write-Host ""

        if ($VPN.Affiliate) {
            Write-Host "  Don't have $($VPN.Name)? Get $($VPN.Bonus)!" -ForegroundColor Green
            Write-Host "  $($VPN.Affiliate)" -ForegroundColor Cyan
            Write-Host ""
        }

        if ($ProtocolInfo.URL) {
            if (Ask-YesNo "Open $($VPN.Name) credential page in your browser now?") {
                Start-Process $ProtocolInfo.URL
                Write-Host ""
                Write-Info "Browser opened. Copy your credentials, then come back here."
                Press-Enter
            }
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
            Type = "openvpn"
            Username = $username.Trim()
            Password = $password.Trim()
        }
    }
}

function Get-ServerCountry {
    Write-Banner
    Write-Host "  STEP 3: SERVER LOCATION" -ForegroundColor Magenta
    Write-Host "  -----------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Pick the closest country to you for best speeds!" -ForegroundColor Yellow
    Write-Host "  (Your VPN's no-logs policy protects you on ANY server)" -ForegroundColor Gray
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
        [hashtable]$ProtocolInfo,
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
# Protocol: $($ProtocolInfo.Protocol)
# ==========================================

# --- VPN PROVIDER ---
VPN_PROVIDER=$($VPN.Provider)

# --- VPN PROTOCOL ---
# Options: openvpn, wireguard
VPN_TYPE=$($ProtocolInfo.Protocol)

# --- VPN CREDENTIALS ---
# Credentials from: $($ProtocolInfo.URL)
"@

    if ($Credentials.Type -eq "wireguard") {
        $content += @"

# WireGuard Configuration
WIREGUARD_PRIVATE_KEY="$($Credentials.PrivateKey)"
WIREGUARD_ADDRESSES="$($Credentials.Address)"
"@
    } else {
        $content += @"

# OpenVPN Service Credentials
VPN_USER="$($Credentials.Username)"
VPN_PASSWORD="$($Credentials.Password)"
"@
    }

    $content += @"


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
      - 8686:8686   # Lidarr
    environment:
      - VPN_SERVICE_PROVIDER=${VPN_PROVIDER}
      - VPN_TYPE=${VPN_TYPE:-openvpn}
      # OpenVPN credentials (used when VPN_TYPE=openvpn)
      - OPENVPN_USER=${VPN_USER:-}
      - OPENVPN_PASSWORD=${VPN_PASSWORD:-}
      # WireGuard credentials (used when VPN_TYPE=wireguard)
      - WIREGUARD_PRIVATE_KEY=${WIREGUARD_PRIVATE_KEY:-}
      - WIREGUARD_ADDRESSES=${WIREGUARD_ADDRESSES:-}
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
      - ${ROOT_DIR}/media/music:/data/music
    restart: always

  # --- SABnzbd (Optional - enable with: docker compose --profile sabnzbd up -d) ---
  sabnzbd:
    image: lscr.io/linuxserver/sabnzbd:latest
    container_name: sabnzbd
    profiles:
      - sabnzbd
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=${TZ}
    ports:
      - 8085:8080   # SABnzbd Web UI
    volumes:
      - ${ROOT_DIR}/config/sabnzbd:/config
      - ${ROOT_DIR}/media/downloads:/data/downloads
    restart: always

  # --- Lidarr (Optional - enable with: docker compose --profile lidarr up -d) ---
  lidarr:
    image: lscr.io/linuxserver/lidarr:latest
    container_name: lidarr
    profiles:
      - lidarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=${TZ}
    volumes:
      - ${ROOT_DIR}/config/lidarr:/config
      - ${ROOT_DIR}/media:/data/media
      - ${ROOT_DIR}/media/downloads:/data/downloads
    network_mode: service:gluetun
    depends_on:
      - gluetun
    restart: always

  # --- Notifications (Optional - enable with: docker compose --profile notifications up -d) ---
  notifiarr:
    image: golift/notifiarr
    container_name: notifiarr
    hostname: notifiarr
    profiles:
      - notifications
    environment:
      - DN_API_KEY=${NOTIFIARR_API_KEY}
      - TZ=${TZ}
    ports:
      - 5454:5454   # Notifiarr Web UI
    volumes:
      - ${ROOT_DIR}/config/notifiarr:/config
    restart: always

  # --- FlareSolverr (Optional - enable with: docker compose --profile flaresolverr up -d) ---
  flaresolverr:
    image: ghcr.io/flaresolverr/flaresolverr:latest
    container_name: flaresolverr
    profiles:
      - flaresolverr
    environment:
      - LOG_LEVEL=info
      - TZ=${TZ}
    ports:
      - 8191:8191   # FlareSolverr
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
    Show-BeginnerTip -Title "What is qBittorrent?" -Body "qBittorrent is a download client for torrents. Think
of it like a download manager. All of its traffic goes
through the VPN tunnel so your ISP never sees it."
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
    Show-BeginnerTip -Title "What is Prowlarr?" -Body "Prowlarr is a search engine that looks across many
torrent sites at once. It connects to Sonarr and Radarr
so they can automatically find the content you want."
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
    Show-BeginnerTip -Title "What is Sonarr?" -Body "Sonarr automates TV show management. Tell it what shows
you want, and it will find episodes, download them via
qBittorrent, and organize them into neat folders."
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
    Show-BeginnerTip -Title "What is Radarr?" -Body "Radarr is just like Sonarr, but for movies. Tell it what
movies you want, and it will find, download, and organize
them automatically."
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
    Write-Host ""
    Write-Host "  If you enabled Lidarr, add it too:" -ForegroundColor Gray
    Write-Host "    - Click '+' and select 'Lidarr'" -ForegroundColor Gray
    Write-Host "    - Prowlarr Server: " -ForegroundColor Gray -NoNewline
    Write-Host "http://localhost:9696" -ForegroundColor Cyan
    Write-Host "    - Lidarr Server: " -ForegroundColor Gray -NoNewline
    Write-Host "http://localhost:8686" -ForegroundColor Cyan
    Write-Host "    - API Key: " -ForegroundColor Gray -NoNewline
    Write-Host "(from Lidarr > Settings > General)" -ForegroundColor Cyan
    Write-Host "    - Click 'Test' then 'Save'" -ForegroundColor Gray

    Press-Enter

    # --- Jellyfin Setup ---
    Show-BeginnerTip -Title "What is Jellyfin?" -Body "Jellyfin is your personal Netflix. It streams your movies
and TV shows to any device — phone, tablet, smart TV, or
browser. It's completely free and open-source."
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
    Write-Host "     For Music (if you enabled Lidarr):" -ForegroundColor Yellow
    Write-Host "       - Content type: Music" -ForegroundColor Gray
    Write-Host "       - Click '+' next to Folders" -ForegroundColor Gray
    Write-Host "       - Enter: " -ForegroundColor Gray -NoNewline
    Write-Host "/data/music" -ForegroundColor Cyan
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
    # Show optional services if they were enabled
    $sabnzbdRunning = docker ps --format '{{.Names}}' 2>$null | Select-String '^sabnzbd$'
    if ($sabnzbdRunning) {
        Write-Host "    SABnzbd:      http://localhost:8085" -ForegroundColor White -NoNewline
        Write-Host " (Usenet Downloads)" -ForegroundColor Gray
    }
    $lidarrRunning = docker ps --format '{{.Names}}' 2>$null | Select-String '^lidarr$'
    if ($lidarrRunning) {
        Write-Host "    Lidarr:       http://localhost:8686" -ForegroundColor White -NoNewline
        Write-Host " (Music Manager)" -ForegroundColor Gray
    }
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

# --- Bonus: Notifiarr Setup ---
function Setup-Notifiarr {
    param([string]$Path)

    Write-Banner
    Write-Host "  BONUS: Discord Notifications with Notifiarr" -ForegroundColor Magenta
    Write-Host "  --------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Want Discord notifications when:" -ForegroundColor White
    Write-Host "    - A movie/show starts downloading?" -ForegroundColor Gray
    Write-Host "    - Downloads complete?" -ForegroundColor Gray
    Write-Host "    - New episodes are available?" -ForegroundColor Gray
    Write-Host "    - Something goes wrong?" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Notifiarr" -ForegroundColor Cyan -NoNewline
    Write-Host " sends beautiful notifications to your Discord server!" -ForegroundColor White
    Write-Host ""

    if (-not (Ask-YesNo "Would you like to set up Discord notifications?")) {
        Write-Host ""
        Write-Info "Skipping Notifiarr setup. You can enable it later!"
        Write-Host ""
        Write-Host "  To enable later, run:" -ForegroundColor Gray
        Write-Host "    docker compose --profile notifications up -d" -ForegroundColor Cyan
        return
    }

    Write-Banner
    Write-Host "  STEP 1: Create Notifiarr Account" -ForegroundColor Magenta
    Write-Host "  --------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  1. Go to " -ForegroundColor White -NoNewline
    Write-Host "https://notifiarr.com" -ForegroundColor Cyan -NoNewline
    Write-Host " and create a FREE account" -ForegroundColor White
    Write-Host "  2. Sign in with Discord (recommended) or email" -ForegroundColor White
    Write-Host "  3. Go to your Profile and copy your " -ForegroundColor White -NoNewline
    Write-Host "API Key" -ForegroundColor Yellow
    Write-Host ""

    if (Ask-YesNo "Open Notifiarr.com in your browser now?") {
        Start-Process "https://notifiarr.com"
        Write-Host ""
        Write-Info "Browser opened. Create account, then copy your API Key."
        Press-Enter
    }

    Write-Host ""
    Write-Host "  Paste your Notifiarr API Key: " -ForegroundColor Yellow -NoNewline
    $apiKey = Read-Host

    if ([string]::IsNullOrWhiteSpace($apiKey)) {
        Write-Error-Custom "No API key provided. Skipping Notifiarr."
        return
    }

    # Add API key to .env
    Add-Content -Path "$Path\.env" -Value ""
    Add-Content -Path "$Path\.env" -Value "# --- NOTIFIARR (Discord Notifications) ---"
    Add-Content -Path "$Path\.env" -Value "NOTIFIARR_API_KEY=$apiKey"

    Write-Success "API Key saved!"
    Write-Host ""

    Write-Step "1" "Starting Notifiarr container..."
    Push-Location $Path
    docker compose --profile notifications up -d 2>&1 | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }
    Pop-Location

    Write-Host ""
    Write-Success "Notifiarr is running!"

    Press-Enter

    Write-Banner
    Write-Host "  STEP 2: Configure Notifiarr" -ForegroundColor Magenta
    Write-Host "  ---------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Press ENTER to open Notifiarr in your browser..." -ForegroundColor Yellow
    Read-Host | Out-Null
    Start-Process "http://localhost:5454"
    Write-Host ""
    Write-Host "  " -NoNewline
    Write-Host " LOGIN " -BackgroundColor DarkBlue -ForegroundColor White
    Write-Host "    Username: " -ForegroundColor White -NoNewline
    Write-Host "admin" -ForegroundColor Cyan
    Write-Host "    Password: " -ForegroundColor White -NoNewline
    Write-Host "(your API key)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  " -NoNewline
    Write-Host " CONNECT YOUR APPS " -BackgroundColor DarkBlue -ForegroundColor White
    Write-Host ""
    Write-Host "  In Notifiarr web UI:" -ForegroundColor Yellow
    Write-Host "    1. Go to 'Starr Apps' in the menu" -ForegroundColor White
    Write-Host "    2. Enable Radarr and add:" -ForegroundColor White
    Write-Host "       - URL: " -ForegroundColor Gray -NoNewline
    Write-Host "http://localhost:7878" -ForegroundColor Cyan
    Write-Host "       - API Key: " -ForegroundColor Gray -NoNewline
    Write-Host "(from Radarr > Settings > General)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "    3. Enable Sonarr and add:" -ForegroundColor White
    Write-Host "       - URL: " -ForegroundColor Gray -NoNewline
    Write-Host "http://localhost:8989" -ForegroundColor Cyan
    Write-Host "       - API Key: " -ForegroundColor Gray -NoNewline
    Write-Host "(from Sonarr > Settings > General)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  On notifiarr.com website:" -ForegroundColor Yellow
    Write-Host "    1. Go to Integrations > Manage" -ForegroundColor White
    Write-Host "    2. Enable Radarr/Sonarr integrations" -ForegroundColor White
    Write-Host "    3. Set up your Discord channel for notifications" -ForegroundColor White
    Write-Host ""
    Write-Host "  That's it! You'll now get Discord notifications!" -ForegroundColor Green

    Press-Enter

    Write-Banner
    Write-Host "  =============================================" -ForegroundColor Green
    Write-Host "       NOTIFIARR SETUP COMPLETE!" -ForegroundColor White
    Write-Host "  =============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Notifiarr Web UI: " -ForegroundColor Yellow -NoNewline
    Write-Host "http://localhost:5454" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Configure notifications at: " -ForegroundColor White -NoNewline
    Write-Host "https://notifiarr.com" -ForegroundColor Cyan
    Write-Host ""
}

# --- Bonus: FlareSolverr Setup ---
function Setup-FlareSolverr {
    param([string]$Path)

    Write-Banner
    Write-Host "  BONUS: Cloudflare Bypass with FlareSolverr" -ForegroundColor Magenta
    Write-Host "  -------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Some indexers are protected by Cloudflare anti-bot challenges." -ForegroundColor White
    Write-Host "  FlareSolverr runs a headless browser to solve these automatically," -ForegroundColor White
    Write-Host "  so Prowlarr can access protected indexers without manual intervention." -ForegroundColor White
    Write-Host ""

    if (-not (Ask-YesNo "Would you like to enable FlareSolverr?")) {
        Write-Host ""
        Write-Info "Skipping FlareSolverr setup. You can enable it later!"
        Write-Host ""
        Write-Host "  To enable later, run:" -ForegroundColor Gray
        Write-Host "    docker compose --profile flaresolverr up -d" -ForegroundColor Cyan
        return
    }

    Write-Host ""
    Write-Step "1" "Starting FlareSolverr container..."
    Push-Location $Path
    docker compose --profile flaresolverr up -d 2>&1 | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }
    Pop-Location

    Write-Host ""
    Write-Success "FlareSolverr is running!"
    Write-Host ""
    Write-Host "  Configure FlareSolverr in Prowlarr:" -ForegroundColor Yellow
    Write-Host "    1. Open Prowlarr: " -ForegroundColor White -NoNewline
    Write-Host "http://localhost:8181" -ForegroundColor Cyan
    Write-Host "    2. Go to: Settings > Indexers" -ForegroundColor White
    Write-Host "    3. Click '+' under 'Indexer Proxies'" -ForegroundColor White
    Write-Host "    4. Select 'FlareSolverr'" -ForegroundColor White
    Write-Host "    5. Set Host to: " -ForegroundColor White -NoNewline
    Write-Host "http://flaresolverr:8191" -ForegroundColor Cyan
    Write-Host "    6. Click 'Test' then 'Save'" -ForegroundColor White
    Write-Host ""
    Write-Host "  Prowlarr will now automatically bypass Cloudflare challenges!" -ForegroundColor Green

    Press-Enter
}

# --- Bonus: SABnzbd Setup ---
function Setup-SABnzbd {
    param([string]$Path)

    Write-Banner
    Write-Host "  BONUS: Usenet Downloads with SABnzbd" -ForegroundColor Magenta
    Write-Host "  -------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  SABnzbd is a Usenet download client — an alternative to torrents." -ForegroundColor White
    Write-Host "  Usenet downloads are SSL-encrypted and typically faster." -ForegroundColor White
    Write-Host "  You'll need a Usenet provider subscription (e.g., Newshosting, Eweka)." -ForegroundColor White
    Write-Host ""

    if (-not (Ask-YesNo "Would you like to enable Usenet downloads (SABnzbd)?")) {
        Write-Host ""
        Write-Info "Skipping SABnzbd setup. You can enable it later!"
        Write-Host ""
        Write-Host "  To enable later, run:" -ForegroundColor Gray
        Write-Host "    docker compose --profile sabnzbd up -d" -ForegroundColor Cyan
        return
    }

    Write-Host ""
    Write-Step "1" "Starting SABnzbd container..."
    Push-Location $Path
    docker compose --profile sabnzbd up -d 2>&1 | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }
    Pop-Location

    Write-Host ""
    Write-Success "SABnzbd is running!"

    Press-Enter

    Write-Banner
    Write-Host "  Configure SABnzbd" -ForegroundColor Magenta
    Write-Host "  -----------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Press ENTER to open SABnzbd in your browser..." -ForegroundColor Yellow
    Read-Host | Out-Null
    Start-Process "http://localhost:8085"
    Write-Host ""
    Write-Host "  1. Follow the SABnzbd Quick-Start Wizard" -ForegroundColor White
    Write-Host ""
    Write-Host "  2. Add your Usenet provider:" -ForegroundColor Yellow
    Write-Host "     - Host: " -ForegroundColor White -NoNewline
    Write-Host "(from your Usenet provider, e.g., news.newshosting.com)" -ForegroundColor Cyan
    Write-Host "     - Port: " -ForegroundColor White -NoNewline
    Write-Host "563" -ForegroundColor Cyan -NoNewline
    Write-Host " (SSL)" -ForegroundColor Gray
    Write-Host "     - Username & Password: " -ForegroundColor White -NoNewline
    Write-Host "(your Usenet account credentials)" -ForegroundColor Cyan
    Write-Host "     - SSL: " -ForegroundColor White -NoNewline
    Write-Host "Yes" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  3. Use SABnzbd as a download client in Sonarr/Radarr/Lidarr:" -ForegroundColor Yellow
    Write-Host "     - Go to: Settings > Download Clients" -ForegroundColor White
    Write-Host "     - Click '+' and select 'SABnzbd'" -ForegroundColor White
    Write-Host "     - Host: " -ForegroundColor White -NoNewline
    Write-Host "sabnzbd" -ForegroundColor Cyan
    Write-Host "     - Port: " -ForegroundColor White -NoNewline
    Write-Host "8080" -ForegroundColor Cyan
    Write-Host "     - API Key: " -ForegroundColor White -NoNewline
    Write-Host "(from SABnzbd > Config > General)" -ForegroundColor Cyan
    Write-Host "     - Click 'Test' then 'Save'" -ForegroundColor White
    Write-Host ""
    Write-Host "  SABnzbd is ready for Usenet downloads!" -ForegroundColor Green

    Press-Enter
}

# --- Bonus: Lidarr Setup ---
function Setup-Lidarr {
    param([string]$Path)

    Write-Banner
    Write-Host "  BONUS: Music Management with Lidarr" -ForegroundColor Magenta
    Write-Host "  ------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Lidarr automatically finds, downloads, and organizes music." -ForegroundColor White
    Write-Host "  It works just like Sonarr/Radarr but for music albums and artists." -ForegroundColor White
    Write-Host "  Your music will be available in Jellyfin for streaming!" -ForegroundColor White
    Write-Host ""

    if (-not (Ask-YesNo "Would you like to enable music management (Lidarr)?")) {
        Write-Host ""
        Write-Info "Skipping Lidarr setup. You can enable it later!"
        Write-Host ""
        Write-Host "  To enable later, run:" -ForegroundColor Gray
        Write-Host "    docker compose --profile lidarr up -d" -ForegroundColor Cyan
        return
    }

    Write-Host ""
    Write-Step "1" "Starting Lidarr container..."
    Push-Location $Path
    docker compose --profile lidarr up -d 2>&1 | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }
    Pop-Location

    Write-Host ""
    Write-Success "Lidarr is running!"

    Press-Enter

    Write-Banner
    Write-Host "  Configure Lidarr" -ForegroundColor Magenta
    Write-Host "  ----------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Press ENTER to open Lidarr in your browser..." -ForegroundColor Yellow
    Read-Host | Out-Null
    Start-Process "http://localhost:8686"
    Write-Host ""
    Write-Host "  1. Create your admin account when prompted" -ForegroundColor White
    Write-Host ""
    Write-Host "  2. Add Root Folder (where music is saved):" -ForegroundColor Yellow
    Write-Host "     - Go to: Settings > Media Management" -ForegroundColor White
    Write-Host "     - Scroll down and click 'Add Root Folder'" -ForegroundColor White
    Write-Host "     - Enter path: " -ForegroundColor White -NoNewline
    Write-Host "/data/media/music" -ForegroundColor Cyan
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
    Write-Host "  4. Copy your API Key (for Prowlarr):" -ForegroundColor Yellow
    Write-Host "     - Go to: Settings > General" -ForegroundColor White
    Write-Host "     - Copy the 'API Key'" -ForegroundColor White
    Write-Host ""
    Write-Host "  5. Connect in Prowlarr:" -ForegroundColor Yellow
    Write-Host "     - Open Prowlarr: " -ForegroundColor White -NoNewline
    Write-Host "http://localhost:8181" -ForegroundColor Cyan
    Write-Host "     - Go to: Settings > Apps" -ForegroundColor White
    Write-Host "     - Click '+' and select 'Lidarr'" -ForegroundColor White
    Write-Host "     - Prowlarr Server: " -ForegroundColor White -NoNewline
    Write-Host "http://localhost:9696" -ForegroundColor Cyan
    Write-Host "     - Lidarr Server: " -ForegroundColor White -NoNewline
    Write-Host "http://localhost:8686" -ForegroundColor Cyan
    Write-Host "     - API Key: " -ForegroundColor White -NoNewline
    Write-Host "(paste the Lidarr API key)" -ForegroundColor Cyan
    Write-Host "     - Click 'Test' then 'Save'" -ForegroundColor White
    Write-Host ""
    Write-Host "  Lidarr is ready! Add artists and let it find your music." -ForegroundColor Green

    Press-Enter
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

    # Experience level selection
    Get-ExperienceLevel
    Show-ArrOverview

    # Collect configuration
    Show-BeginnerTip -Title "Why do you need a VPN?" -Body "Your ISP (internet provider) can see everything you
download. A VPN encrypts your traffic so they can't.
Only the torrent containers use the VPN — your normal
browsing stays on your regular connection."
    $vpn = Get-VPNProvider
    Write-Host ""
    Write-Success "Selected: $($vpn.Name)"
    Press-Enter

    $protocolInfo = Get-VPNProtocol -VPN $vpn
    Write-Host ""
    Write-Success "Selected: $($protocolInfo.Protocol)"
    Press-Enter

    $credentials = Get-VPNCredentials -VPN $vpn -ProtocolInfo $protocolInfo
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
    Write-Host "  VPN Protocol:    $($protocolInfo.Protocol)" -ForegroundColor White
    if ($credentials.Type -eq "wireguard") {
        Write-Host "  WG Private Key:  $($credentials.PrivateKey.Substring(0, [Math]::Min(10, $credentials.PrivateKey.Length)))..." -ForegroundColor White
        Write-Host "  WG Address:      $($credentials.Address)" -ForegroundColor White
    } else {
        Write-Host "  VPN Username:    $($credentials.Username)" -ForegroundColor White
        Write-Host "  VPN Password:    $("*" * $credentials.Password.Length)" -ForegroundColor White
    }
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
    New-Item -ItemType Directory -Path "$InstallPath\media\music" -Force | Out-Null
    Write-Success "Directories created"

    Write-Step "2" "Generating .env file..."
    New-EnvFile -Path $InstallPath -VPN $vpn -ProtocolInfo $protocolInfo -Credentials $credentials -Country $country -Timezone $timezone
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
        Setup-Notifiarr -Path $InstallPath
        Setup-FlareSolverr -Path $InstallPath
        Setup-SABnzbd -Path $InstallPath
        Setup-Lidarr -Path $InstallPath
    } else {
        Write-Host ""
        Write-Error-Custom "Setup failed. Please check your VPN credentials."
        Write-Host ""
        Write-Host "  Common fixes:" -ForegroundColor Yellow
        if ($protocolInfo.Protocol -eq "wireguard") {
            Write-Host "    1. Make sure your WireGuard Private Key is correct" -ForegroundColor White
            Write-Host "    2. Verify your WireGuard Address matches the config" -ForegroundColor White
            if ($protocolInfo.URL) {
                Write-Host "    3. Generate a new config from: " -ForegroundColor White -NoNewline
                Write-Host $protocolInfo.URL -ForegroundColor Cyan
            } else {
                Write-Host "    3. Generate a new config from your $($vpn.Name) account" -ForegroundColor White
            }
        } else {
            Write-Host "    1. Make sure you're using 'Service Credentials' from $($vpn.Name)" -ForegroundColor White
            Write-Host "    2. NOT your email/password login" -ForegroundColor White
            if ($protocolInfo.URL) {
                Write-Host "    3. Get credentials from: " -ForegroundColor White -NoNewline
                Write-Host $protocolInfo.URL -ForegroundColor Cyan
            } else {
                Write-Host "    3. Get credentials from your $($vpn.Name) account" -ForegroundColor White
            }
        }
        Write-Host ""
        Write-Host "  To retry, run this script again." -ForegroundColor Gray
    }
}

# Run
Main
