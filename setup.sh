#!/bin/bash
# ============================================================
# PRIVACY BOX - One-Click Media Server Setup
# Created by Tom Spark | https://youtube.com/@TomSparkReviews
#
# LICENSE: MIT with Attribution - You MUST credit Tom Spark
#          if you share, modify, or create content based on this.
#
# GitHub: https://github.com/loponai/tomsparkprivacyarrsuite
# ============================================================

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BEGINNER_MODE=false

# --- WSL2 Detection ---
IS_WSL=false
if grep -qi microsoft /proc/version 2>/dev/null; then
    IS_WSL=true
fi

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
NC='\033[0m' # No Color

# --- Helper Functions ---
write_banner() {
    clear
    echo ""
    echo -e "  ${CYAN}=====================================================${NC}"
    echo -e "       ${WHITE}PRIVACY BOX - Secure Media Server Setup${NC}"
    echo -e "  ${CYAN}=====================================================${NC}"
    echo -e "         ${DARKGRAY}Created by ${YELLOW}TOM SPARK${DARKGRAY} | v${VERSION}${NC}"
    echo -e "      ${DARKGRAY}YouTube: youtube.com/@TomSparkReviews${NC}"
    echo -e "  ${CYAN}=====================================================${NC}"
    echo -e "   ${DARKGRAY}(c) 2026 Tom Spark. Licensed under MIT+Attribution.${NC}"
    echo -e "   ${RED}Unauthorized copying without credit = DMCA takedown.${NC}"
    echo -e "  ${CYAN}=====================================================${NC}"
    echo ""
}

write_step() {
    echo -e "  ${YELLOW}[$1]${NC} ${WHITE}$2${NC}"
}

write_success() {
    echo -e "  ${GREEN}[OK]${NC} ${WHITE}$1${NC}"
}

write_error() {
    echo -e "  ${RED}[X]${NC} ${WHITE}$1${NC}"
}

write_info() {
    echo -e "  ${CYAN}[i]${NC} ${GRAY}$1${NC}"
}

write_warning() {
    echo -e "  ${YELLOW}[!]${NC} ${WHITE}$1${NC}"
}

press_enter() {
    echo ""
    echo -e "  ${DARKGRAY}Press ENTER to continue...${NC}"
    read -r
}

ask_yes_no() {
    echo ""
    echo -ne "  ${YELLOW}$1 (Y/N): ${NC}"
    read -r response
    [[ "$response" =~ ^[Yy]$ ]]
}

open_url() {
    local url="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "$url"
    elif [[ "$IS_WSL" == "true" ]]; then
        explorer.exe "$url" 2>/dev/null || wslview "$url" 2>/dev/null || \
        echo -e "  ${CYAN}Open: $url${NC}"
    else
        xdg-open "$url" 2>/dev/null || echo -e "  ${CYAN}Open: $url${NC}"
    fi
}

# --- Beginner Mode ---
show_beginner_tip() {
    local title="$1"
    local body="$2"

    if [[ "$BEGINNER_MODE" != "true" ]]; then
        return
    fi

    echo ""
    echo -e "  ${CYAN}┌──────────────────────────────────────────────────┐${NC}"
    echo -e "  ${CYAN}│${NC}  ${WHITE}💡 $title${NC}"
    echo -e "  ${CYAN}├──────────────────────────────────────────────────┤${NC}"
    while IFS= read -r line; do
        echo -e "  ${CYAN}│${NC}  ${GRAY}$line${NC}"
    done <<< "$body"
    echo -e "  ${CYAN}└──────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${DARKGRAY}Press ENTER to continue...${NC}"
    read -r
}

get_experience_level() {
    write_banner
    echo -e "  ${MAGENTA}EXPERIENCE LEVEL${NC}"
    echo -e "  ${DARKGRAY}----------------${NC}"
    echo ""
    echo -e "  ${WHITE}How familiar are you with the ARR suite?${NC}"
    echo ""
    echo -e "    ${GREEN}1. I'm brand new to ARR${NC}  ${GRAY}(show me extra explanations)${NC}"
    echo -e "    ${CYAN}2. I'm familiar with ARR${NC} ${GRAY}(skip the intro tips)${NC}"
    echo ""
    echo -ne "  ${YELLOW}Select (1-2) [default: 1]: ${NC}"
    read -r choice

    case "$choice" in
        2)
            BEGINNER_MODE=false
            write_success "Experienced mode — skipping beginner tips."
            ;;
        *)
            BEGINNER_MODE=true
            write_success "Beginner mode — extra tips will be shown throughout setup."
            ;;
    esac
}

show_arr_overview() {
    if [[ "$BEGINNER_MODE" != "true" ]]; then
        return
    fi

    write_banner
    echo -e "  ${MAGENTA}WHAT IS THE ARR SUITE?${NC}"
    echo -e "  ${DARKGRAY}----------------------${NC}"
    echo ""
    echo -e "  ${WHITE}The ARR suite is a collection of apps that work together${NC}"
    echo -e "  ${WHITE}to automatically find, download, and organize media:${NC}"
    echo ""
    echo -e "  ${CYAN}┌─────────────┬──────────────────────────────────────────┐${NC}"
    echo -e "  ${CYAN}│${NC} ${YELLOW}Service${NC}     ${CYAN}│${NC} ${WHITE}What it does${NC}                              ${CYAN}│${NC}"
    echo -e "  ${CYAN}├─────────────┼──────────────────────────────────────────┤${NC}"
    echo -e "  ${CYAN}│${NC} ${GREEN}qBittorrent${NC} ${CYAN}│${NC} ${GRAY}Downloads files (through VPN for safety)${NC}  ${CYAN}│${NC}"
    echo -e "  ${CYAN}│${NC} ${GREEN}Prowlarr${NC}    ${CYAN}│${NC} ${GRAY}Searches torrent sites for content${NC}       ${CYAN}│${NC}"
    echo -e "  ${CYAN}│${NC} ${GREEN}Sonarr${NC}      ${CYAN}│${NC} ${GRAY}Finds & organizes TV shows automatically${NC} ${CYAN}│${NC}"
    echo -e "  ${CYAN}│${NC} ${GREEN}Radarr${NC}      ${CYAN}│${NC} ${GRAY}Finds & organizes movies automatically${NC}   ${CYAN}│${NC}"
    echo -e "  ${CYAN}│${NC} ${GREEN}Jellyfin${NC}    ${CYAN}│${NC} ${GRAY}Streams your media (like personal Netflix)${NC}${CYAN}│${NC}"
    echo -e "  ${CYAN}├─────────────┼──────────────────────────────────────────┤${NC}"
    echo -e "  ${CYAN}│${NC} ${YELLOW}Optional:${NC}   ${CYAN}│${NC}                                          ${CYAN}│${NC}"
    echo -e "  ${CYAN}│${NC} ${GREEN}SABnzbd${NC}     ${CYAN}│${NC} ${GRAY}Downloads from Usenet (alternative to torrents)${NC}${CYAN}│${NC}"
    echo -e "  ${CYAN}│${NC} ${GREEN}Lidarr${NC}      ${CYAN}│${NC} ${GRAY}Finds & organizes music automatically${NC}   ${CYAN}│${NC}"
    echo -e "  ${CYAN}└─────────────┴──────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${WHITE}How they connect:${NC}"
    echo ""
    echo -e "  ${GRAY}You search in${NC} ${GREEN}Sonarr/Radarr${NC} ${GRAY}→${NC} ${GREEN}Prowlarr${NC} ${GRAY}finds it →${NC} ${GREEN}qBittorrent${NC} ${GRAY}downloads it${NC}"
    echo -e "  ${GRAY}→${NC} ${GREEN}Sonarr/Radarr${NC} ${GRAY}organizes it →${NC} ${GREEN}Jellyfin${NC} ${GRAY}streams it to your devices${NC}"
    echo ""
    echo -e "  ${YELLOW}All torrent traffic is routed through your VPN for privacy.${NC}"

    press_enter
}

# --- Pre-Flight Checks ---
test_docker_installed() {
    write_step "1" "Checking if Docker is installed..."

    if ! command -v docker &> /dev/null; then
        write_error "Docker is NOT installed!"
        echo ""
        echo -e "  ${WHITE}Please install Docker first:${NC}"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo -e "  ${CYAN}https://www.docker.com/products/docker-desktop/${NC}"
            echo -e "  ${WHITE}Download Docker Desktop for Mac${NC}"
        else
            echo -e "  ${CYAN}https://docs.docker.com/engine/install/${NC}"
            echo -e "  ${WHITE}Or run: curl -fsSL https://get.docker.com | sh${NC}"
        fi
        return 1
    fi
    write_success "Docker is installed"
    return 0
}

test_docker_running() {
    write_step "2" "Checking if Docker is running..."

    if ! docker info &> /dev/null; then
        write_error "Docker is NOT running!"
        echo ""
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo -e "  ${WHITE}Please start Docker Desktop and wait for it to be ready.${NC}"
        else
            echo -e "  ${WHITE}Please start Docker: ${CYAN}sudo systemctl start docker${NC}"
        fi
        return 1
    fi
    write_success "Docker is running"
    return 0
}

# --- VPN Provider Selection ---
get_vpn_provider() {
    write_banner
    echo -e "  ${MAGENTA}STEP 1: CHOOSE YOUR VPN${NC}"
    echo -e "  ${DARKGRAY}-----------------------${NC}"
    echo ""
    echo -e "  ${WHITE}RECOMMENDED ${GRAY}(Tested 10+ years for speed & security):${NC}"
    echo ""
    echo -e "    ${GREEN}1. NordVPN${NC}     ${GRAY}- nordvpn.tomspark.tech${NC} ${GREEN}(4 extra months FREE!)${NC}"
    echo -e "    ${CYAN}2. ProtonVPN${NC}   ${GRAY}- protonvpn.tomspark.tech${NC} ${CYAN}(3 months FREE!)${NC}"
    echo -e "    ${YELLOW}3. Surfshark${NC}   ${GRAY}- surfshark.tomspark.tech${NC} ${YELLOW}(3 extra months FREE!)${NC}"
    echo ""
    echo -e "  ${WHITE}OTHER SUPPORTED VPNs:${NC}"
    echo ""
    echo -e "    ${GRAY}4. Other VPN provider${NC}"
    echo ""
    echo -ne "  ${YELLOW}Select (1-4) [default: 1]: ${NC}"
    read -r choice

    # Reset optional vars
    VPN_AFFILIATE=""
    VPN_BONUS=""
    VPN_URL=""

    case "$choice" in
        2)
            VPN_PROVIDER="protonvpn"
            VPN_NAME="ProtonVPN"
            VPN_AFFILIATE="https://protonvpn.tomspark.tech/"
            VPN_BONUS="3 months FREE"
            SUPPORTS_WIREGUARD=true
            ;;
        3)
            VPN_PROVIDER="surfshark"
            VPN_NAME="Surfshark"
            VPN_AFFILIATE="https://surfshark.tomspark.tech/"
            VPN_BONUS="3 extra months FREE"
            SUPPORTS_WIREGUARD=true
            ;;
        4)
            get_other_vpn_provider
            ;;
        *)
            VPN_PROVIDER="nordvpn"
            VPN_NAME="NordVPN"
            VPN_URL="https://my.nordaccount.com/dashboard/nordvpn/manual-configuration/"
            VPN_AFFILIATE="https://nordvpn.tomspark.tech/"
            VPN_BONUS="4 extra months FREE"
            SUPPORTS_WIREGUARD=false
            VPN_TYPE="openvpn"
            ;;
    esac

    # Ask ProtonVPN users about free vs paid tier
    FREE_ONLY="off"
    if [[ "$VPN_PROVIDER" == "protonvpn" ]]; then
        echo ""
        echo -e "  ${WHITE}Are you on the ProtonVPN Free plan?${NC}"
        echo ""
        echo -e "    ${GREEN}1. Paid${NC}   ${GRAY}(Plus, Unlimited, Visionary)${NC}"
        echo -e "    ${CYAN}2. Free${NC}   ${GRAY}(limited countries, no port forwarding)${NC}"
        echo ""
        echo -ne "  ${YELLOW}Select (1-2) [default: 1]: ${NC}"
        read -r tier_choice
        if [[ "$tier_choice" == "2" ]]; then
            FREE_ONLY="on"
            echo ""
            write_info "Free tier selected. Only free servers will be used."
        fi
    fi

    echo ""
    write_success "Selected: $VPN_NAME"
}

get_other_vpn_provider() {
    write_banner
    echo -e "  ${MAGENTA}OTHER VPN PROVIDERS${NC}"
    echo -e "  ${DARKGRAY}-------------------${NC}"
    echo ""
    echo -e "  ${WHITE}Select your VPN provider:${NC}"
    echo ""
    echo -e "    ${WHITE} 1. Mullvad${NC}"
    echo -e "    ${WHITE} 2. Private Internet Access (PIA)${NC}"
    echo -e "    ${WHITE} 3. Windscribe${NC}"
    echo -e "    ${WHITE} 4. CyberGhost${NC}"
    echo -e "    ${WHITE} 5. IPVanish${NC}"
    echo -e "    ${WHITE} 6. AirVPN${NC}"
    echo -e "    ${WHITE} 7. Custom (any Gluetun-supported provider)${NC}"
    echo ""
    echo -ne "  ${YELLOW}Select (1-7) [default: 1]: ${NC}"
    read -r other_choice

    case "$other_choice" in
        2)
            VPN_PROVIDER="private internet access"
            VPN_NAME="Private Internet Access"
            SUPPORTS_WIREGUARD=true
            ;;
        3)
            VPN_PROVIDER="windscribe"
            VPN_NAME="Windscribe"
            SUPPORTS_WIREGUARD=true
            ;;
        4)
            VPN_PROVIDER="cyberghost"
            VPN_NAME="CyberGhost"
            SUPPORTS_WIREGUARD=true
            ;;
        5)
            VPN_PROVIDER="ipvanish"
            VPN_NAME="IPVanish"
            SUPPORTS_WIREGUARD=false
            VPN_TYPE="openvpn"
            ;;
        6)
            VPN_PROVIDER="airvpn"
            VPN_NAME="AirVPN"
            SUPPORTS_WIREGUARD=true
            ;;
        7)
            echo ""
            echo -e "  ${WHITE}Enter the Gluetun provider name exactly as listed at:${NC}"
            echo -e "  ${CYAN}https://github.com/qdm12/gluetun-wiki/tree/main/setup/providers${NC}"
            echo ""
            echo -ne "  ${YELLOW}Provider name: ${NC}"
            read -r VPN_PROVIDER
            VPN_NAME="$VPN_PROVIDER"
            echo ""
            echo -ne "  ${YELLOW}Does this provider support WireGuard? (Y/N) [default: N]: ${NC}"
            read -r wg_response
            if [[ "$wg_response" =~ ^[Yy]$ ]]; then
                SUPPORTS_WIREGUARD=true
            else
                SUPPORTS_WIREGUARD=false
                VPN_TYPE="openvpn"
            fi
            ;;
        *)
            VPN_PROVIDER="mullvad"
            VPN_NAME="Mullvad"
            SUPPORTS_WIREGUARD=true
            ;;
    esac
}

# --- VPN Protocol Selection (ProtonVPN/Surfshark only) ---
get_vpn_protocol() {
    if [[ "$SUPPORTS_WIREGUARD" != "true" ]]; then
        VPN_TYPE="openvpn"
        return
    fi

    write_banner
    echo -e "  ${MAGENTA}STEP 1b: CHOOSE VPN PROTOCOL${NC}"
    echo -e "  ${DARKGRAY}----------------------------${NC}"
    echo ""
    echo -e "  ${WHITE}Which protocol would you like to use?${NC}"
    echo ""
    echo -e "    ${GREEN}1. OpenVPN${NC}     ${GRAY}- Traditional, widely compatible${NC}"
    echo -e "    ${CYAN}2. WireGuard${NC}   ${GRAY}- Faster, more modern (Recommended)${NC}"
    echo ""
    echo -ne "  ${YELLOW}Select (1-2) [default: 1]: ${NC}"
    read -r protocol_choice

    case "$protocol_choice" in
        2)
            VPN_TYPE="wireguard"
            case "$VPN_PROVIDER" in
                protonvpn) VPN_URL="https://account.proton.me/u/0/vpn/WireGuard" ;;
                surfshark) VPN_URL="https://my.surfshark.com/vpn/manual-setup/main/wireguard" ;;
            esac
            ;;
        *)
            VPN_TYPE="openvpn"
            case "$VPN_PROVIDER" in
                protonvpn) VPN_URL="https://account.proton.me/u/0/vpn/OpenVpnIKEv2" ;;
                surfshark) VPN_URL="https://my.surfshark.com/vpn/manual-setup/main/openvpn" ;;
            esac
            ;;
    esac

    echo ""
    write_success "Selected: $VPN_TYPE"
}

# --- Credential Collection ---
get_vpn_credentials() {
    write_banner

    if [[ "$VPN_TYPE" == "wireguard" ]]; then
        echo -e "  ${MAGENTA}STEP 2: WIREGUARD CREDENTIALS${NC}"
        echo -e "  ${DARKGRAY}-----------------------------${NC}"
        echo ""
        write_warning "You need your WireGuard configuration from $VPN_NAME"
        echo ""
        echo -e "  ${WHITE}You can paste EITHER:${NC}"
        echo -e "  ${CYAN}  Option A:${NC} ${WHITE}The entire WireGuard config block${NC} ${GRAY}(we'll extract what we need)${NC}"
        echo -e "  ${CYAN}  Option B:${NC} ${WHITE}Just the Private Key value${NC}"
        echo ""
        echo -e "  ${WHITE}How to get them:${NC}"
        if [[ -n "$VPN_URL" ]]; then
            echo -e "  ${GRAY}1. Go to: ${CYAN}${VPN_URL}${NC}"
        else
            echo -e "  ${GRAY}1. Log in to your ${WHITE}${VPN_NAME}${GRAY} account${NC}"
            echo -e "  ${GRAY}   Find the manual/service credentials or WireGuard config page${NC}"
        fi
        echo -e "  ${GRAY}2. Generate a new WireGuard configuration${NC}"
        echo -e "  ${GRAY}3. Copy the config or just the Private Key and Address${NC}"
        echo ""

        if [[ -n "$VPN_AFFILIATE" ]]; then
            echo -e "  ${GREEN}Don't have ${VPN_NAME}? Get ${VPN_BONUS}!${NC}"
            echo -e "  ${CYAN}${VPN_AFFILIATE}${NC}"
            echo ""
        fi

        if [[ -n "$VPN_URL" ]]; then
            if ask_yes_no "Open $VPN_NAME WireGuard page in your browser now?"; then
                open_url "$VPN_URL"
                echo ""
                write_info "Browser opened. Generate a config, then copy the Private Key and Address."
                press_enter
            fi
        fi

        echo ""
        echo -e "  ${DARKGRAY}TIP: Ctrl+V may not paste here. Use right-click or Shift+Insert to paste.${NC}"
        echo ""
        echo -e "  ${WHITE}Paste your WireGuard Private Key (or full .conf file contents).${NC}"
        echo -e "  ${DARKGRAY}Tip: Pasting just the Private Key value is easiest.${NC}"
        echo ""
        echo -ne "  ${YELLOW}> ${NC}"
        read -r first_line

        # Strip carriage returns from first line (CMD/WSL paste adds \r)
        first_line="${first_line//$'\r'/}"

        # Check if user pasted a full config block (starts with [Interface] or comment)
        if [[ "$first_line" == "["* ]] || [[ "$first_line" == "#"* ]]; then
            # Detected config block - read remaining lines WITHOUT any echo first
            WIREGUARD_PRIVATE_KEY=""
            WIREGUARD_ADDRESSES=""
            for _ in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
                if ! read -r -t 10 line; then
                    [[ -z "$line" ]] && break
                fi
                line="${line//$'\r'/}"
                [[ "$line" == "["* && "$line" != "[Interface]" ]] && break
                if [[ "$line" == PrivateKey* ]]; then
                    WIREGUARD_PRIVATE_KEY="${line#*= }"
                fi
                if [[ "$line" == Address* ]]; then
                    WIREGUARD_ADDRESSES="${line#*= }"
                fi
                [[ -n "$WIREGUARD_PRIVATE_KEY" && -n "$WIREGUARD_ADDRESSES" ]] && break
            done
            # Drain remaining pasted lines
            while read -r -t 2 _; do :; done

            # Trim whitespace
            WIREGUARD_PRIVATE_KEY="${WIREGUARD_PRIVATE_KEY%% }"
            WIREGUARD_PRIVATE_KEY="${WIREGUARD_PRIVATE_KEY## }"
            WIREGUARD_ADDRESSES="${WIREGUARD_ADDRESSES%% }"
            WIREGUARD_ADDRESSES="${WIREGUARD_ADDRESSES## }"

            if [[ -n "$WIREGUARD_PRIVATE_KEY" && -n "$WIREGUARD_ADDRESSES" ]]; then
                echo ""
                write_success "Extracted from config:"
                echo -e "    ${WHITE}Private Key: ${CYAN}${WIREGUARD_PRIVATE_KEY:0:10}...${NC}"
                echo -e "    ${WHITE}Address:     ${CYAN}${WIREGUARD_ADDRESSES}${NC}"
            else
                # Auto-extract failed - drain stdin thoroughly then ask manually
                echo ""
                write_warning "Could not auto-extract from config. Please enter values separately."
                echo -e "  ${GRAY}From your .conf file, copy the value after 'PrivateKey = '${NC}"
                echo -e "  ${GRAY}(It's a long base64 string, e.g. yAnz5TF+lXXJte14tji3zlMNq+hd2rYUIgJBgB3fBmk=)${NC}"
                echo ""
                # Wait for any in-flight paste data to arrive, then drain it
                sleep 3
                while read -r -t 1 _; do :; done
                echo -ne "  ${YELLOW}WG Private Key: ${NC}"
                read -r WIREGUARD_PRIVATE_KEY
                WIREGUARD_PRIVATE_KEY="${WIREGUARD_PRIVATE_KEY//$'\r'/}"
                echo -ne "  ${YELLOW}WG Address (e.g., 10.2.0.2/32): ${NC}"
                read -r WIREGUARD_ADDRESSES
                WIREGUARD_ADDRESSES="${WIREGUARD_ADDRESSES//$'\r'/}"
            fi
        else
            # User pasted just the private key directly
            WIREGUARD_PRIVATE_KEY="$first_line"

            echo -ne "  ${YELLOW}Enter your WireGuard Address (e.g., 10.2.0.2/32): ${NC}"
            read -r WIREGUARD_ADDRESSES
        fi

        # Trim whitespace
        WIREGUARD_PRIVATE_KEY=$(echo "$WIREGUARD_PRIVATE_KEY" | xargs)
        WIREGUARD_ADDRESSES=$(echo "$WIREGUARD_ADDRESSES" | xargs)

        if [[ -z "$WIREGUARD_PRIVATE_KEY" || -z "$WIREGUARD_ADDRESSES" ]]; then
            write_error "Private Key and Address cannot be empty!"
            return 1
        fi

        # Clear OpenVPN vars since we're using WireGuard
        VPN_USERNAME=""
        VPN_PASSWORD=""
    else
        echo -e "  ${MAGENTA}STEP 2: VPN CREDENTIALS${NC}"
        echo -e "  ${DARKGRAY}-----------------------${NC}"
        echo ""
        write_warning "You need $VPN_NAME 'Service Credentials' (NOT your email/password!)"
        echo ""
        echo -e "  ${WHITE}How to get them:${NC}"
        if [[ -n "$VPN_URL" ]]; then
            echo -e "  ${GRAY}1. Go to: ${CYAN}${VPN_URL}${NC}"
        else
            echo -e "  ${GRAY}1. Log in to your ${WHITE}${VPN_NAME}${GRAY} account${NC}"
            echo -e "  ${GRAY}   Find the manual/service credentials or OpenVPN setup page${NC}"
        fi
        echo -e "  ${GRAY}2. Look for 'Manual Setup' or 'OpenVPN' credentials${NC}"
        echo -e "  ${GRAY}3. Copy the Username and Password shown there${NC}"
        echo ""

        if [[ -n "$VPN_AFFILIATE" ]]; then
            echo -e "  ${GREEN}Don't have ${VPN_NAME}? Get ${VPN_BONUS}!${NC}"
            echo -e "  ${CYAN}${VPN_AFFILIATE}${NC}"
            echo ""
        fi

        if [[ -n "$VPN_URL" ]]; then
            if ask_yes_no "Open $VPN_NAME credential page in your browser now?"; then
                open_url "$VPN_URL"
                echo ""
                write_info "Browser opened. Copy your credentials, then come back here."
                press_enter
            fi
        fi

        echo ""
        echo -e "  ${DARKGRAY}TIP: Ctrl+V may not paste here. Use right-click or Shift+Insert to paste.${NC}"
        echo ""
        echo -ne "  ${YELLOW}Enter your Service Username: ${NC}"
        read -r VPN_USERNAME

        echo -ne "  ${YELLOW}Enter your Service Password: ${NC}"
        read -r VPN_PASSWORD

        if [[ -z "$VPN_USERNAME" || -z "$VPN_PASSWORD" ]]; then
            write_error "Username and password cannot be empty!"
            return 1
        fi

        # Clear WireGuard vars since we're using OpenVPN
        WIREGUARD_PRIVATE_KEY=""
        WIREGUARD_ADDRESSES=""
    fi

    return 0
}

get_server_country() {
    write_banner
    echo -e "  ${MAGENTA}STEP 3: SERVER LOCATION${NC}"
    echo -e "  ${DARKGRAY}-----------------------${NC}"
    echo ""
    echo -e "  ${YELLOW}Pick the closest country to you for best speeds!${NC}"
    echo -e "  ${GRAY}(Your VPN's no-logs policy protects you on ANY server)${NC}"
    echo ""
    echo -e "  ${WHITE}Popular choices:${NC}"
    echo -e "    ${GRAY}1. United States${NC}"
    echo -e "    ${GRAY}2. United Kingdom${NC}"
    echo -e "    ${GRAY}3. Canada${NC}"
    echo -e "    ${GRAY}4. Netherlands${NC}"
    echo -e "    ${GRAY}5. Custom${NC}"
    echo ""
    echo -ne "  ${YELLOW}Select (1-5) [default: 1]: ${NC}"
    read -r choice

    case "$choice" in
        2) SERVER_COUNTRY="United Kingdom" ;;
        3) SERVER_COUNTRY="Canada" ;;
        4) SERVER_COUNTRY="Netherlands" ;;
        5)
            echo -ne "  ${YELLOW}Enter country name (capitalize first letter): ${NC}"
            read -r SERVER_COUNTRY
            ;;
        *) SERVER_COUNTRY="United States" ;;
    esac
}

get_timezone() {
    write_banner
    echo -e "  ${MAGENTA}STEP 4: TIMEZONE${NC}"
    echo -e "  ${DARKGRAY}----------------${NC}"
    echo ""
    echo -e "  ${WHITE}Common timezones:${NC}"
    echo -e "    ${GRAY}1. America/Los_Angeles (Pacific)${NC}"
    echo -e "    ${GRAY}2. America/Denver (Mountain)${NC}"
    echo -e "    ${GRAY}3. America/Chicago (Central)${NC}"
    echo -e "    ${GRAY}4. America/New_York (Eastern)${NC}"
    echo -e "    ${GRAY}5. Europe/London${NC}"
    echo -e "    ${GRAY}6. Europe/Berlin${NC}"
    echo -e "    ${GRAY}7. Custom${NC}"
    echo ""
    echo -ne "  ${YELLOW}Select (1-7) [default: 1]: ${NC}"
    read -r choice

    case "$choice" in
        2) TIMEZONE="America/Denver" ;;
        3) TIMEZONE="America/Chicago" ;;
        4) TIMEZONE="America/New_York" ;;
        5) TIMEZONE="Europe/London" ;;
        6) TIMEZONE="Europe/Berlin" ;;
        7)
            echo -ne "  ${YELLOW}Enter timezone (e.g., Australia/Sydney): ${NC}"
            read -r TIMEZONE
            ;;
        *) TIMEZONE="America/Los_Angeles" ;;
    esac
}

# --- File Generation ---
create_env_file() {
    cat > "$SCRIPT_DIR/.env" << EOF
# ==========================================
# TOM SPARK'S PRIVACY BOX CONFIG
# Created by Tom Spark | youtube.com/@TomSparkReviews
#
# VPN: ${VPN_NAME} (${VPN_AFFILIATE})
# Protocol: ${VPN_TYPE}
# ==========================================

# --- VPN PROVIDER ---
VPN_PROVIDER=${VPN_PROVIDER}

# --- VPN PROTOCOL ---
# Options: openvpn, wireguard
VPN_TYPE=${VPN_TYPE}

# --- VPN CREDENTIALS ---
# Credentials from: ${VPN_URL}
EOF

    if [[ "$VPN_TYPE" == "wireguard" ]]; then
        cat >> "$SCRIPT_DIR/.env" << EOF
# WireGuard Configuration
WIREGUARD_PRIVATE_KEY="${WIREGUARD_PRIVATE_KEY}"
WIREGUARD_ADDRESSES="${WIREGUARD_ADDRESSES}"
EOF
    else
        cat >> "$SCRIPT_DIR/.env" << EOF
# OpenVPN Service Credentials
VPN_USER="${VPN_USERNAME}"
VPN_PASSWORD="${VPN_PASSWORD}"
EOF
    fi

    cat >> "$SCRIPT_DIR/.env" << EOF

# --- SERVER LOCATION ---
SERVER_COUNTRIES=${SERVER_COUNTRY}

# --- FREE TIER (ProtonVPN only) ---
FREE_ONLY=${FREE_ONLY}

# --- SYSTEM SETTINGS ---
TZ=${TIMEZONE}
ROOT_DIR=.
EOF
}

# --- Docker Operations ---
start_privacy_box() {
    write_banner
    echo -e "  ${MAGENTA}LAUNCHING PRIVACY BOX${NC}"
    echo -e "  ${DARKGRAY}---------------------${NC}"
    echo ""

    cd "$SCRIPT_DIR" || exit 1

    write_step "1" "Pulling Docker images (this may take a few minutes on first run)..."
    echo ""
    docker compose pull </dev/null 2>&1 | sed 's/^/      /'

    echo ""
    write_step "2" "Starting containers..."
    echo ""
    docker compose up -d </dev/null 2>&1 | sed 's/^/      /'

    echo ""
    write_step "3" "Waiting for VPN to connect..."

    max_attempts=30
    attempt=0
    connected=false

    while [[ $attempt -lt $max_attempts ]] && [[ "$connected" == "false" ]]; do
        sleep 2
        ((attempt++))

        health=$(docker inspect --format='{{.State.Health.Status}}' gluetun 2>/dev/null)
        if [[ "$health" == "healthy" ]]; then
            connected=true
        fi

        echo -ne "${YELLOW}.${NC}"
    done

    echo ""
    echo ""

    if [[ "$connected" == "true" ]]; then
        ip=$(docker logs gluetun </dev/null 2>&1 | grep "Public IP address is" | tail -1 | sed 's/.*Public IP address is //' | cut -d' ' -f1)
        if [[ -n "$ip" ]]; then
            write_success "VPN Connected! Your IP: $ip"
        else
            write_success "VPN Connected!"
        fi
        return 0
    else
        write_error "VPN connection timed out. Checking logs..."
        echo ""
        docker logs gluetun </dev/null 2>&1 | grep -E "AUTH_FAILED|error|Error" | tail -5 | sed 's/^/      /'
        return 1
    fi
}

# --- Setup Guide ---
show_setup_guide() {
    # --- qBittorrent Setup ---
    show_beginner_tip "What is qBittorrent?" \
"qBittorrent is a download client for torrents. Think
of it like a download manager. All of its traffic goes
through the VPN tunnel so your ISP never sees it."
    write_banner
    echo -e "  ${MAGENTA}SETUP GUIDE: qBittorrent (Step 1 of 4)${NC}"
    echo -e "  ${DARKGRAY}--------------------------------------${NC}"
    echo ""
    echo -e "  ${YELLOW}Press ENTER to open qBittorrent in your browser...${NC}"
    read -r
    open_url "http://localhost:8080"
    echo ""
    echo -e "  ${YELLOW}Login:${NC}"
    echo -e "    ${WHITE}Username: ${CYAN}admin${NC}"
    echo -e "    ${WHITE}Password: ${CYAN}(check the command below)${NC}"
    echo ""
    echo -e "  ${WHITE} IMPORTANT ${NC}"
    echo -e "  ${WHITE}qBittorrent generates a random password on first run.${NC}"
    echo ""
    echo -e "  ${YELLOW}To find your password:${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "    ${WHITE}1. Open a new Terminal window (Cmd + T)${NC}"
    else
        echo -e "    ${WHITE}1. Open a new terminal window${NC}"
    fi
    echo -e "    ${WHITE}2. Paste this command:${NC}"
    echo ""
    echo -e "       ${CYAN}docker logs qbittorrent 2>&1 | grep password${NC}"
    echo ""
    echo -e "    ${WHITE}3. Press Enter - your password will appear${NC}"
    echo -e "    ${WHITE}4. Copy the password and use it to log in above${NC}"
    echo ""
    echo -e "  ${YELLOW}After logging in, change your password:${NC}"
    echo -e "    ${GRAY}Tools > Options > Web UI > Password${NC}"
    echo ""
    echo -e "  ${WHITE} VPN VERIFICATION ${NC}"
    echo -e "  ${WHITE}Go to: Tools > Options > Advanced${NC}"
    echo -e "  ${WHITE}Look for 'Network Interface' - it should say: ${GREEN}tun0${NC}"
    echo -e "  ${GRAY}This proves your traffic is going through the VPN tunnel!${NC}"

    press_enter

    # --- Prowlarr Setup ---
    show_beginner_tip "What is Prowlarr?" \
"Prowlarr is a search engine that looks across many
torrent sites at once. It connects to Sonarr and Radarr
so they can automatically find the content you want."
    write_banner
    echo -e "  ${MAGENTA}SETUP GUIDE: Prowlarr (Step 2 of 4)${NC}"
    echo -e "  ${DARKGRAY}-----------------------------------${NC}"
    echo ""
    echo -e "  ${YELLOW}Press ENTER to open Prowlarr in your browser...${NC}"
    read -r
    open_url "http://localhost:8181"
    echo ""
    echo -e "  ${WHITE} IMPORTANT ${NC}"
    echo ""
    echo -e "  ${WHITE}1. Create your admin account when prompted${NC}"
    echo ""
    echo -e "  ${YELLOW}2. Add Indexers:${NC}"
    echo -e "     ${WHITE}- Click 'Indexers' in the sidebar${NC}"
    echo -e "     ${WHITE}- Click '+ Add Indexer'${NC}"
    echo -e "     ${RED}- CRITICAL: Change 'Language' filter from 'en-US' to 'Any'${NC}"
    echo -e "       ${GRAY}(Otherwise you'll only see ~6 indexers instead of 400+)${NC}"
    echo -e "     ${WHITE}- Add: 1337x, TorrentGalaxy, or your preferred sites${NC}"
    echo ""
    echo -e "  ${GRAY}3. We'll connect Prowlarr to Sonarr/Radarr in the next steps${NC}"

    press_enter

    # --- Sonarr Setup ---
    show_beginner_tip "What is Sonarr?" \
"Sonarr automates TV show management. Tell it what shows
you want, and it will find episodes, download them via
qBittorrent, and organize them into neat folders."
    write_banner
    echo -e "  ${MAGENTA}SETUP GUIDE: Sonarr (Step 3 of 4)${NC}"
    echo -e "  ${DARKGRAY}---------------------------------${NC}"
    echo ""
    echo -e "  ${YELLOW}Press ENTER to open Sonarr in your browser...${NC}"
    read -r
    open_url "http://localhost:8989"
    echo ""
    echo -e "  ${WHITE}1. Create your admin account when prompted${NC}"
    echo ""
    echo -e "  ${YELLOW}2. Add Root Folder (where TV shows are saved):${NC}"
    echo -e "     ${WHITE}- Go to: Settings > Media Management${NC}"
    echo -e "     ${WHITE}- Scroll down and click 'Add Root Folder'${NC}"
    echo -e "     ${WHITE}- Enter path: ${CYAN}/data/media/tv${NC}"
    echo -e "     ${WHITE}- Click 'OK'${NC}"
    echo ""
    echo -e "  ${YELLOW}3. Add Download Client:${NC}"
    echo -e "     ${WHITE}- Go to: Settings > Download Clients${NC}"
    echo -e "     ${WHITE}- Click '+' and select 'qBittorrent'${NC}"
    echo -e "     ${WHITE}- Host: ${CYAN}localhost${NC}"
    echo -e "     ${WHITE}- Port: ${CYAN}8080${NC}"
    echo -e "     ${WHITE}- Username: ${CYAN}admin${NC}"
    echo -e "     ${WHITE}- Password: ${CYAN}(your qBittorrent password)${NC}"
    echo -e "     ${WHITE}- Click 'Test' then 'Save'${NC}"
    echo ""
    echo -e "  ${YELLOW}4. Copy your API Key:${NC}"
    echo -e "     ${WHITE}- Go to: Settings > General${NC}"
    echo -e "     ${WHITE}- Copy the 'API Key' (you'll need this for Prowlarr)${NC}"

    press_enter

    # --- Radarr Setup ---
    show_beginner_tip "What is Radarr?" \
"Radarr is just like Sonarr, but for movies. Tell it what
movies you want, and it will find, download, and organize
them automatically."
    write_banner
    echo -e "  ${MAGENTA}SETUP GUIDE: Radarr (Step 4 of 4)${NC}"
    echo -e "  ${DARKGRAY}---------------------------------${NC}"
    echo ""
    echo -e "  ${YELLOW}Press ENTER to open Radarr in your browser...${NC}"
    read -r
    open_url "http://localhost:7878"
    echo ""
    echo -e "  ${WHITE}1. Create your admin account when prompted${NC}"
    echo ""
    echo -e "  ${YELLOW}2. Add Root Folder (where movies are saved):${NC}"
    echo -e "     ${WHITE}- Go to: Settings > Media Management${NC}"
    echo -e "     ${WHITE}- Scroll down and click 'Add Root Folder'${NC}"
    echo -e "     ${WHITE}- Enter path: ${CYAN}/data/media/movies${NC}"
    echo -e "     ${WHITE}- Click 'OK'${NC}"
    echo ""
    echo -e "  ${YELLOW}3. Add Download Client (same as Sonarr):${NC}"
    echo -e "     ${WHITE}- Go to: Settings > Download Clients${NC}"
    echo -e "     ${WHITE}- Click '+' and select 'qBittorrent'${NC}"
    echo -e "     ${WHITE}- Host: ${CYAN}localhost${NC}"
    echo -e "     ${WHITE}- Port: ${CYAN}8080${NC}"
    echo -e "     ${WHITE}- Username/Password: same as before${NC}"
    echo -e "     ${WHITE}- Click 'Test' then 'Save'${NC}"
    echo ""
    echo -e "  ${YELLOW}4. Copy your API Key:${NC}"
    echo -e "     ${WHITE}- Go to: Settings > General${NC}"
    echo -e "     ${WHITE}- Copy the 'API Key' (you'll need this for Prowlarr)${NC}"

    press_enter

    # --- Connect Prowlarr ---
    write_banner
    echo -e "  ${MAGENTA}FINAL STEP: Connect Prowlarr to Apps${NC}"
    echo -e "  ${DARKGRAY}------------------------------------${NC}"
    echo ""
    echo -e "  ${YELLOW}Press ENTER to open Prowlarr in your browser...${NC}"
    read -r
    open_url "http://localhost:8181"
    echo ""
    echo -e "  ${YELLOW}Go to: Settings > Apps${NC}"
    echo ""
    echo -e "  ${WHITE}Add Sonarr:${NC}"
    echo -e "    ${GRAY}- Click '+' and select 'Sonarr'${NC}"
    echo -e "    ${GRAY}- Prowlarr Server: ${CYAN}http://localhost:9696${NC}"
    echo -e "    ${GRAY}- Sonarr Server: ${CYAN}http://localhost:8989${NC}"
    echo -e "    ${GRAY}- API Key: ${CYAN}(paste the Sonarr API key you copied)${NC}"
    echo -e "    ${GRAY}- Click 'Test' then 'Save'${NC}"
    echo ""
    echo -e "  ${WHITE}Add Radarr:${NC}"
    echo -e "    ${GRAY}- Click '+' and select 'Radarr'${NC}"
    echo -e "    ${GRAY}- Prowlarr Server: ${CYAN}http://localhost:9696${NC}"
    echo -e "    ${GRAY}- Radarr Server: ${CYAN}http://localhost:7878${NC}"
    echo -e "    ${GRAY}- API Key: ${CYAN}(paste the Radarr API key you copied)${NC}"
    echo -e "    ${GRAY}- Click 'Test' then 'Save'${NC}"
    echo ""
    echo -e "  ${GRAY}If you enabled Lidarr, add it too:${NC}"
    echo -e "    ${GRAY}- Click '+' and select 'Lidarr'${NC}"
    echo -e "    ${GRAY}- Prowlarr Server: ${CYAN}http://localhost:9696${NC}"
    echo -e "    ${GRAY}- Lidarr Server: ${CYAN}http://localhost:8686${NC}"
    echo -e "    ${GRAY}- API Key: ${CYAN}(from Lidarr > Settings > General)${NC}"
    echo -e "    ${GRAY}- Click 'Test' then 'Save'${NC}"

    press_enter

    # --- Jellyfin Setup ---
    show_beginner_tip "What is Jellyfin?" \
"Jellyfin is your personal Netflix. It streams your movies
and TV shows to any device — phone, tablet, smart TV, or
browser. It's completely free and open-source."
    write_banner
    echo -e "  ${MAGENTA}SETUP GUIDE: Jellyfin (Media Server)${NC}"
    echo -e "  ${DARKGRAY}------------------------------------${NC}"
    echo ""
    echo -e "  ${GREEN} JELLYFIN IS ALREADY INSTALLED! ${NC}"
    echo ""
    echo -e "  ${GRAY}Jellyfin is included in your Privacy Box. Watch your media on any device!${NC}"
    echo ""
    echo -e "  ${YELLOW}Press ENTER to open Jellyfin in your browser...${NC}"
    read -r
    open_url "http://localhost:8096"
    echo ""
    echo -e "  ${WHITE} STEP 1: Initial Setup ${NC}"
    echo ""
    echo -e "  ${WHITE}1. Select your language and click Next${NC}"
    echo -e "  ${WHITE}2. Create your admin username and password${NC}"
    echo -e "  ${WHITE}3. Click 'Add Media Library' and add:${NC}"
    echo ""
    echo -e "     ${YELLOW}For Movies:${NC}"
    echo -e "       ${GRAY}- Content type: Movies${NC}"
    echo -e "       ${GRAY}- Click '+' next to Folders${NC}"
    echo -e "       ${GRAY}- Enter: ${CYAN}/data/movies${NC}"
    echo ""
    echo -e "     ${YELLOW}For TV Shows:${NC}"
    echo -e "       ${GRAY}- Content type: Shows${NC}"
    echo -e "       ${GRAY}- Click '+' next to Folders${NC}"
    echo -e "       ${GRAY}- Enter: ${CYAN}/data/tvshows${NC}"
    echo ""
    echo -e "     ${YELLOW}For Music (if you enabled Lidarr):${NC}"
    echo -e "       ${GRAY}- Content type: Music${NC}"
    echo -e "       ${GRAY}- Click '+' next to Folders${NC}"
    echo -e "       ${GRAY}- Enter: ${CYAN}/data/music${NC}"
    echo ""
    echo -e "  ${WHITE}4. Finish the setup wizard${NC}"
    echo ""
    echo -e "  ${WHITE} STEP 2: Watch on Other Devices ${NC}"
    echo ""
    echo -e "  ${YELLOW}Same Network (Home WiFi):${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "    ${WHITE}1. Find this Mac's IP: ${CYAN}ifconfig | grep 'inet '${NC}"
    else
        echo -e "    ${WHITE}1. Find this computer's IP: ${CYAN}ip addr${NC} or ${CYAN}hostname -I${NC}"
    fi
    echo -e "       ${GRAY}Look for your local IP (e.g., 192.168.1.100)${NC}"
    echo -e "    ${WHITE}2. On your TV/phone/tablet, download the Jellyfin app${NC}"
    echo -e "    ${WHITE}3. Enter server address: ${CYAN}http://YOUR-IP:8096${NC}"
    echo ""
    echo -e "  ${WHITE} CAN'T CONNECT FROM OTHER DEVICES? ${NC}"
    echo ""
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "  ${YELLOW}macOS Firewall may be blocking connections:${NC}"
        echo -e "    ${WHITE}System Preferences > Security & Privacy > Firewall > Firewall Options${NC}"
        echo -e "    ${WHITE}Add Docker or allow incoming connections${NC}"
    else
        echo -e "  ${YELLOW}Linux firewall may be blocking connections:${NC}"
        echo -e "    ${CYAN}sudo ufw allow 8096/tcp${NC}"
    fi

    press_enter

    # --- Remote Access Setup (Optional) ---
    write_banner
    echo -e "  ${MAGENTA}OPTIONAL: Watch Your Media From Anywhere${NC}"
    echo -e "  ${DARKGRAY}-----------------------------------------${NC}"
    echo ""
    echo -e "  ${WHITE}Want to access your media outside your home (hotel, work, etc.)?${NC}"
    echo -e "  ${GRAY}Use a secure mesh network - NO port forwarding needed!${NC}"
    echo ""
    echo -e "  ${WHITE} OPTION 1: NordVPN Meshnet (You already have NordVPN!) ${NC}"
    echo ""
    echo -e "  ${YELLOW}On this computer:${NC}"
    echo -e "    ${WHITE}1. Install NordVPN app: ${CYAN}https://nordvpn.com/download/${NC}"
    echo -e "    ${WHITE}2. Sign in and go to 'Meshnet' in the left sidebar${NC}"
    echo -e "    ${WHITE}3. Turn ON Meshnet${NC}"
    echo -e "    ${WHITE}4. Note your device's Meshnet name (e.g., my-pc.nord)${NC}"
    echo ""
    echo -e "  ${YELLOW}On your phone/laptop (when away from home):${NC}"
    echo -e "    ${WHITE}1. Install NordVPN app and sign in with same account${NC}"
    echo -e "    ${WHITE}2. Go to Meshnet and turn it ON${NC}"
    echo -e "    ${WHITE}3. Your PC will appear under 'Your devices'${NC}"
    echo -e "    ${WHITE}4. Open Jellyfin/Emby app and connect to:${NC}"
    echo -e "       ${CYAN}http://your-pc-name.nord:8096${NC} ${GRAY}(Jellyfin)${NC}"
    echo -e "       ${CYAN}http://your-pc-name.nord:8920${NC} ${GRAY}(Emby)${NC}"
    echo ""
    echo -e "  ${WHITE} OPTION 2: Tailscale (Free alternative) ${NC}"
    echo ""
    echo -e "  ${YELLOW}On this computer:${NC}"
    echo -e "    ${WHITE}1. Download Tailscale: ${CYAN}https://tailscale.com/download${NC}"
    echo -e "    ${WHITE}2. Install and sign in (Google/Microsoft/etc.)${NC}"
    echo -e "    ${WHITE}3. Note your Tailscale IP (starts with 100.x.x.x)${NC}"
    echo ""
    echo -e "  ${YELLOW}On your phone/laptop:${NC}"
    echo -e "    ${WHITE}1. Install Tailscale app and sign in with same account${NC}"
    echo -e "    ${WHITE}2. Open Jellyfin/Emby app and connect to:${NC}"
    echo -e "       ${CYAN}http://100.x.x.x:8096${NC} ${GRAY}(use your actual Tailscale IP)${NC}"
    echo ""
    echo -e "  ${WHITE} WHY THIS IS SAFE ${NC}"
    echo ""
    echo -e "  ${GRAY}Both options create an encrypted tunnel directly between your devices.${NC}"
    echo -e "  ${GRAY}Nothing is exposed to the internet - no hackers can find your server!${NC}"
    echo -e "  ${GRAY}This does NOT interfere with your torrent VPN (that runs in Docker).${NC}"

    press_enter

    # --- Complete ---
    write_banner
    echo ""
    echo -e "  ${GREEN}=============================================${NC}"
    echo -e "       ${WHITE}PRIVACY BOX SETUP COMPLETE!${NC}"
    echo -e "  ${GREEN}=============================================${NC}"
    echo ""
    echo -e "  ${YELLOW}Your Services:${NC}"
    echo -e "    ${WHITE}qBittorrent:  http://localhost:8080${NC}"
    echo -e "    ${WHITE}Prowlarr:     http://localhost:8181${NC}"
    echo -e "    ${WHITE}Sonarr:       http://localhost:8989${NC}"
    echo -e "    ${WHITE}Radarr:       http://localhost:7878${NC}"
    echo -e "    ${CYAN}Jellyfin:     http://localhost:8096${NC} ${GRAY}(Media Server)${NC}"
    # Show optional services if they were enabled
    if docker ps --format '{{.Names}}' 2>/dev/null | grep -q '^sabnzbd$'; then
        echo -e "    ${WHITE}SABnzbd:      http://localhost:8085${NC} ${GRAY}(Usenet Downloads)${NC}"
    fi
    if docker ps --format '{{.Names}}' 2>/dev/null | grep -q '^lidarr$'; then
        echo -e "    ${WHITE}Lidarr:       http://localhost:8686${NC} ${GRAY}(Music Manager)${NC}"
    fi
    echo ""
    echo -e "  ${YELLOW}Your media folder:${NC}"
    echo -e "    ${GRAY}${SCRIPT_DIR}/media/${NC}"
    echo ""
    echo -e "  ${GREEN}Your traffic is now secured through the VPN!${NC}"
    echo ""
    echo -e "  ${DARKGRAY}=============================================${NC}"
    echo -e "  ${YELLOW}IS IT RUNNING?${NC}"
    echo -e "  ${DARKGRAY}=============================================${NC}"
    echo -e "  ${WHITE}Your Privacy Box is currently ${GREEN}RUNNING${WHITE}!${NC}"
    echo -e "  ${GRAY}It will keep running in the background.${NC}"
    echo ""
    echo -e "  ${YELLOW}Useful Commands (run from this folder):${NC}"
    echo -e "    ${GRAY}Start:   docker compose up -d${NC}"
    echo -e "    ${GRAY}Stop:    docker compose down${NC}"
    echo -e "    ${GRAY}Restart: docker compose restart${NC}"
    echo -e "    ${GRAY}Status:  docker ps${NC}"
    echo ""
    echo -e "  ${CYAN}=============================================${NC}"
    echo -e "  ${YELLOW}Created by TOM SPARK${NC}"
    echo -e "  ${WHITE}Subscribe: youtube.com/@TomSparkReviews${NC}"
    echo ""
    echo -e "  ${WHITE}VPN Deals:${NC}"
    echo -e "    ${GREEN}NordVPN:   nordvpn.tomspark.tech   (4 extra months FREE!)${NC}"
    echo -e "    ${CYAN}ProtonVPN: protonvpn.tomspark.tech (3 months FREE!)${NC}"
    echo -e "    ${YELLOW}Surfshark: surfshark.tomspark.tech (3 extra months FREE!)${NC}"
    echo -e "  ${CYAN}=============================================${NC}"
    echo ""
    echo -e "  ${YELLOW}Questions? Join the Discord!${NC}"
    echo -e "  ${CYAN}https://discord.gg/uPdRcKxEVS${NC}"
    echo ""
}

# --- Bonus: Notifiarr Setup ---
setup_notifiarr() {
    write_banner
    echo -e "  ${MAGENTA}BONUS: Discord Notifications with Notifiarr${NC}"
    echo -e "  ${DARKGRAY}--------------------------------------------${NC}"
    echo ""
    echo -e "  ${WHITE}Want Discord notifications when:${NC}"
    echo -e "    ${GRAY}- A movie/show starts downloading?${NC}"
    echo -e "    ${GRAY}- Downloads complete?${NC}"
    echo -e "    ${GRAY}- New episodes are available?${NC}"
    echo -e "    ${GRAY}- Something goes wrong?${NC}"
    echo ""
    echo -e "  ${CYAN}Notifiarr${NC} ${WHITE}sends beautiful notifications to your Discord server!${NC}"
    echo ""

    if ! ask_yes_no "Would you like to set up Discord notifications?"; then
        echo ""
        write_info "Skipping Notifiarr setup. You can enable it later!"
        echo ""
        echo -e "  ${GRAY}To enable later, run:${NC}"
        echo -e "    ${CYAN}docker compose --profile notifications up -d${NC}"
        return 0
    fi

    write_banner
    echo -e "  ${MAGENTA}STEP 1: Create Notifiarr Account${NC}"
    echo -e "  ${DARKGRAY}--------------------------------${NC}"
    echo ""
    echo -e "  ${WHITE}1. Go to ${CYAN}https://notifiarr.com${WHITE} and create a FREE account${NC}"
    echo -e "  ${WHITE}2. Sign in with Discord (recommended) or email${NC}"
    echo -e "  ${WHITE}3. Go to your Profile and copy your ${YELLOW}API Key${NC}"
    echo ""

    if ask_yes_no "Open Notifiarr.com in your browser now?"; then
        open_url "https://notifiarr.com"
        echo ""
        write_info "Browser opened. Create account, then copy your API Key."
        press_enter
    fi

    echo ""
    echo -e "  ${DARKGRAY}TIP: Ctrl+V may not paste here. Use right-click or Shift+Insert to paste.${NC}"
    echo ""
    echo -ne "  ${YELLOW}Paste your Notifiarr API Key: ${NC}"
    read -r NOTIFIARR_API_KEY

    if [[ -z "$NOTIFIARR_API_KEY" ]]; then
        write_error "No API key provided. Skipping Notifiarr."
        return 1
    fi

    # Add API key to .env
    echo "" >> "$SCRIPT_DIR/.env"
    echo "# --- NOTIFIARR (Discord Notifications) ---" >> "$SCRIPT_DIR/.env"
    echo "NOTIFIARR_API_KEY=${NOTIFIARR_API_KEY}" >> "$SCRIPT_DIR/.env"

    write_success "API Key saved!"
    echo ""

    write_step "1" "Starting Notifiarr container..."
    cd "$SCRIPT_DIR" || exit 1
    docker compose --profile notifications up -d </dev/null 2>&1 | sed 's/^/      /'

    echo ""
    write_success "Notifiarr is running!"

    press_enter

    write_banner
    echo -e "  ${MAGENTA}STEP 2: Configure Notifiarr${NC}"
    echo -e "  ${DARKGRAY}---------------------------${NC}"
    echo ""
    echo -e "  ${YELLOW}Press ENTER to open Notifiarr in your browser...${NC}"
    read -r
    open_url "http://localhost:5454"
    echo ""
    echo -e "  ${WHITE} LOGIN ${NC}"
    echo -e "    ${WHITE}Username: ${CYAN}admin${NC}"
    echo -e "    ${WHITE}Password: ${CYAN}(your API key)${NC}"
    echo ""
    echo -e "  ${WHITE} CONNECT YOUR APPS ${NC}"
    echo ""
    echo -e "  ${YELLOW}In Notifiarr web UI:${NC}"
    echo -e "    ${WHITE}1. Go to 'Starr Apps' in the menu${NC}"
    echo -e "    ${WHITE}2. Enable Radarr and add:${NC}"
    echo -e "       ${GRAY}- URL: ${CYAN}http://localhost:7878${NC}"
    echo -e "       ${GRAY}- API Key: ${CYAN}(from Radarr > Settings > General)${NC}"
    echo ""
    echo -e "    ${WHITE}3. Enable Sonarr and add:${NC}"
    echo -e "       ${GRAY}- URL: ${CYAN}http://localhost:8989${NC}"
    echo -e "       ${GRAY}- API Key: ${CYAN}(from Sonarr > Settings > General)${NC}"
    echo ""
    echo -e "  ${YELLOW}On notifiarr.com website:${NC}"
    echo -e "    ${WHITE}1. Go to Integrations > Manage${NC}"
    echo -e "    ${WHITE}2. Enable Radarr/Sonarr integrations${NC}"
    echo -e "    ${WHITE}3. Set up your Discord channel for notifications${NC}"
    echo ""
    echo -e "  ${GREEN}That's it! You'll now get Discord notifications!${NC}"

    press_enter

    write_banner
    echo -e "  ${GREEN}=============================================${NC}"
    echo -e "       ${WHITE}NOTIFIARR SETUP COMPLETE!${NC}"
    echo -e "  ${GREEN}=============================================${NC}"
    echo ""
    echo -e "  ${YELLOW}Notifiarr Web UI:${NC} ${CYAN}http://localhost:5454${NC}"
    echo ""
    echo -e "  ${WHITE}Configure notifications at: ${CYAN}https://notifiarr.com${NC}"
    echo ""
}

# --- Bonus: FlareSolverr Setup ---
setup_flaresolverr() {
    write_banner
    echo -e "  ${MAGENTA}BONUS: Cloudflare Bypass with FlareSolverr${NC}"
    echo -e "  ${DARKGRAY}-------------------------------------------${NC}"
    echo ""
    echo -e "  ${WHITE}Some indexers are protected by Cloudflare anti-bot challenges.${NC}"
    echo -e "  ${WHITE}FlareSolverr runs a headless browser to solve these automatically,${NC}"
    echo -e "  ${WHITE}so Prowlarr can access protected indexers without manual intervention.${NC}"
    echo ""

    if ! ask_yes_no "Would you like to enable FlareSolverr?"; then
        echo ""
        write_info "Skipping FlareSolverr setup. You can enable it later!"
        echo ""
        echo -e "  ${GRAY}To enable later, run:${NC}"
        echo -e "    ${CYAN}docker compose --profile flaresolverr up -d${NC}"
        return 0
    fi

    echo ""
    write_step "1" "Starting FlareSolverr container..."
    cd "$SCRIPT_DIR" || exit 1
    docker compose --profile flaresolverr up -d </dev/null 2>&1 | sed 's/^/      /'

    echo ""
    write_success "FlareSolverr is running!"
    echo ""
    echo -e "  ${YELLOW}Configure FlareSolverr in Prowlarr:${NC}"
    echo -e "    ${WHITE}1. Open Prowlarr: ${CYAN}http://localhost:8181${NC}"
    echo -e "    ${WHITE}2. Go to: Settings > Indexers${NC}"
    echo -e "    ${WHITE}3. Click '+' under 'Indexer Proxies'${NC}"
    echo -e "    ${WHITE}4. Select 'FlareSolverr'${NC}"
    echo -e "    ${WHITE}5. Set Host to: ${CYAN}http://flaresolverr:8191${NC}"
    echo -e "    ${WHITE}6. Click 'Test' then 'Save'${NC}"
    echo ""
    echo -e "  ${GREEN}Prowlarr will now automatically bypass Cloudflare challenges!${NC}"

    press_enter
}

# --- Bonus: SABnzbd Setup ---
setup_sabnzbd() {
    write_banner
    echo -e "  ${MAGENTA}BONUS: Usenet Downloads with SABnzbd${NC}"
    echo -e "  ${DARKGRAY}-------------------------------------${NC}"
    echo ""
    echo -e "  ${WHITE}SABnzbd is a Usenet download client — an alternative to torrents.${NC}"
    echo -e "  ${WHITE}Usenet downloads are SSL-encrypted and typically faster.${NC}"
    echo -e "  ${WHITE}You'll need a Usenet provider subscription (e.g., Newshosting, Eweka).${NC}"
    echo ""

    if ! ask_yes_no "Would you like to enable Usenet downloads (SABnzbd)?"; then
        echo ""
        write_info "Skipping SABnzbd setup. You can enable it later!"
        echo ""
        echo -e "  ${GRAY}To enable later, run:${NC}"
        echo -e "    ${CYAN}docker compose --profile sabnzbd up -d${NC}"
        return 0
    fi

    echo ""
    write_step "1" "Starting SABnzbd container..."
    cd "$SCRIPT_DIR" || exit 1
    docker compose --profile sabnzbd up -d </dev/null 2>&1 | sed 's/^/      /'

    echo ""
    write_success "SABnzbd is running!"

    press_enter

    write_banner
    echo -e "  ${MAGENTA}Configure SABnzbd${NC}"
    echo -e "  ${DARKGRAY}-----------------${NC}"
    echo ""
    echo -e "  ${YELLOW}Press ENTER to open SABnzbd in your browser...${NC}"
    read -r
    open_url "http://localhost:8085"
    echo ""
    echo -e "  ${WHITE}1. Follow the SABnzbd Quick-Start Wizard${NC}"
    echo ""
    echo -e "  ${YELLOW}2. Add your Usenet provider:${NC}"
    echo -e "     ${WHITE}- Host: ${CYAN}(from your Usenet provider, e.g., news.newshosting.com)${NC}"
    echo -e "     ${WHITE}- Port: ${CYAN}563${NC} ${GRAY}(SSL)${NC}"
    echo -e "     ${WHITE}- Username & Password: ${CYAN}(your Usenet account credentials)${NC}"
    echo -e "     ${WHITE}- SSL: ${CYAN}Yes${NC}"
    echo ""
    echo -e "  ${YELLOW}3. Use SABnzbd as a download client in Sonarr/Radarr/Lidarr:${NC}"
    echo -e "     ${WHITE}- Go to: Settings > Download Clients${NC}"
    echo -e "     ${WHITE}- Click '+' and select 'SABnzbd'${NC}"
    echo -e "     ${WHITE}- Host: ${CYAN}sabnzbd${NC}"
    echo -e "     ${WHITE}- Port: ${CYAN}8080${NC}"
    echo -e "     ${WHITE}- API Key: ${CYAN}(from SABnzbd > Config > General)${NC}"
    echo -e "     ${WHITE}- Click 'Test' then 'Save'${NC}"
    echo ""
    echo -e "  ${GREEN}SABnzbd is ready for Usenet downloads!${NC}"

    press_enter
}

# --- Bonus: Lidarr Setup ---
setup_lidarr() {
    write_banner
    echo -e "  ${MAGENTA}BONUS: Music Management with Lidarr${NC}"
    echo -e "  ${DARKGRAY}------------------------------------${NC}"
    echo ""
    echo -e "  ${WHITE}Lidarr automatically finds, downloads, and organizes music.${NC}"
    echo -e "  ${WHITE}It works just like Sonarr/Radarr but for music albums and artists.${NC}"
    echo -e "  ${WHITE}Your music will be available in Jellyfin for streaming!${NC}"
    echo ""

    if ! ask_yes_no "Would you like to enable music management (Lidarr)?"; then
        echo ""
        write_info "Skipping Lidarr setup. You can enable it later!"
        echo ""
        echo -e "  ${GRAY}To enable later, run:${NC}"
        echo -e "    ${CYAN}docker compose --profile lidarr up -d${NC}"
        return 0
    fi

    echo ""
    write_step "1" "Starting Lidarr container..."
    cd "$SCRIPT_DIR" || exit 1
    docker compose --profile lidarr up -d </dev/null 2>&1 | sed 's/^/      /'

    echo ""
    write_success "Lidarr is running!"

    press_enter

    write_banner
    echo -e "  ${MAGENTA}Configure Lidarr${NC}"
    echo -e "  ${DARKGRAY}----------------${NC}"
    echo ""
    echo -e "  ${YELLOW}Press ENTER to open Lidarr in your browser...${NC}"
    read -r
    open_url "http://localhost:8686"
    echo ""
    echo -e "  ${WHITE}1. Create your admin account when prompted${NC}"
    echo ""
    echo -e "  ${YELLOW}2. Add Root Folder (where music is saved):${NC}"
    echo -e "     ${WHITE}- Go to: Settings > Media Management${NC}"
    echo -e "     ${WHITE}- Scroll down and click 'Add Root Folder'${NC}"
    echo -e "     ${WHITE}- Enter path: ${CYAN}/data/media/music${NC}"
    echo -e "     ${WHITE}- Click 'OK'${NC}"
    echo ""
    echo -e "  ${YELLOW}3. Add Download Client:${NC}"
    echo -e "     ${WHITE}- Go to: Settings > Download Clients${NC}"
    echo -e "     ${WHITE}- Click '+' and select 'qBittorrent'${NC}"
    echo -e "     ${WHITE}- Host: ${CYAN}localhost${NC}"
    echo -e "     ${WHITE}- Port: ${CYAN}8080${NC}"
    echo -e "     ${WHITE}- Username: ${CYAN}admin${NC}"
    echo -e "     ${WHITE}- Password: ${CYAN}(your qBittorrent password)${NC}"
    echo -e "     ${WHITE}- Click 'Test' then 'Save'${NC}"
    echo ""
    echo -e "  ${YELLOW}4. Copy your API Key (for Prowlarr):${NC}"
    echo -e "     ${WHITE}- Go to: Settings > General${NC}"
    echo -e "     ${WHITE}- Copy the 'API Key'${NC}"
    echo ""
    echo -e "  ${YELLOW}5. Connect in Prowlarr:${NC}"
    echo -e "     ${WHITE}- Open Prowlarr: ${CYAN}http://localhost:8181${NC}"
    echo -e "     ${WHITE}- Go to: Settings > Apps${NC}"
    echo -e "     ${WHITE}- Click '+' and select 'Lidarr'${NC}"
    echo -e "     ${WHITE}- Prowlarr Server: ${CYAN}http://localhost:9696${NC}"
    echo -e "     ${WHITE}- Lidarr Server: ${CYAN}http://localhost:8686${NC}"
    echo -e "     ${WHITE}- API Key: ${CYAN}(paste the Lidarr API key)${NC}"
    echo -e "     ${WHITE}- Click 'Test' then 'Save'${NC}"
    echo ""
    echo -e "  ${GREEN}Lidarr is ready! Add artists and let it find your music.${NC}"

    press_enter
}

# --- Main Execution ---
main() {
    write_banner

    # Pre-flight checks
    if ! test_docker_installed; then
        press_enter
        exit 1
    fi

    if ! test_docker_running; then
        press_enter
        exit 1
    fi

    write_success "Pre-flight checks passed!"
    press_enter

    # Experience level selection
    get_experience_level
    show_arr_overview

    # Collect configuration
    show_beginner_tip "Why do you need a VPN?" \
"Your ISP (internet provider) can see everything you
download. A VPN encrypts your traffic so they can't.
Only the torrent containers use the VPN — your normal
browsing stays on your regular connection."
    get_vpn_provider
    get_vpn_protocol

    if ! get_vpn_credentials; then
        exit 1
    fi

    get_server_country
    get_timezone

    # Confirmation
    write_banner
    echo -e "  ${MAGENTA}CONFIGURATION SUMMARY${NC}"
    echo -e "  ${DARKGRAY}---------------------${NC}"
    echo ""
    echo -e "  ${WHITE}Install Path:    ${SCRIPT_DIR}${NC}"
    echo -e "  ${WHITE}VPN Provider:    ${VPN_NAME}${NC}"
    echo -e "  ${WHITE}VPN Protocol:    ${VPN_TYPE}${NC}"
    if [[ "$VPN_TYPE" == "wireguard" ]]; then
        echo -e "  ${WHITE}WG Private Key:  $(echo "$WIREGUARD_PRIVATE_KEY" | head -c 10)...${NC}"
        echo -e "  ${WHITE}WG Address:      ${WIREGUARD_ADDRESSES}${NC}"
    else
        echo -e "  ${WHITE}VPN Username:    ${VPN_USERNAME}${NC}"
        echo -e "  ${WHITE}VPN Password:    $(printf '*%.0s' $(seq 1 ${#VPN_PASSWORD}))${NC}"
    fi
    echo -e "  ${WHITE}Server Country:  ${SERVER_COUNTRY}${NC}"
    echo -e "  ${WHITE}Timezone:        ${TIMEZONE}${NC}"
    echo ""

    if ! ask_yes_no "Proceed with installation?"; then
        echo ""
        write_info "Installation cancelled."
        exit 0
    fi

    # Create directory structure
    write_banner
    echo -e "  ${MAGENTA}CREATING FILES${NC}"
    echo -e "  ${DARKGRAY}--------------${NC}"
    echo ""

    write_step "1" "Creating directories..."
    mkdir -p "$SCRIPT_DIR/config"
    mkdir -p "$SCRIPT_DIR/media/downloads"
    mkdir -p "$SCRIPT_DIR/media/tv"
    mkdir -p "$SCRIPT_DIR/media/movies"
    mkdir -p "$SCRIPT_DIR/media/music"
    write_success "Directories created"

    write_step "2" "Generating .env file..."
    create_env_file
    write_success ".env file created"

    press_enter

    # Launch
    if start_privacy_box; then
        press_enter
        show_setup_guide
        setup_notifiarr
        setup_flaresolverr
        setup_sabnzbd
        setup_lidarr
    else
        echo ""
        write_error "Setup failed. Please check your VPN credentials."
        echo ""
        echo -e "  ${YELLOW}Common fixes:${NC}"
        if [[ "$VPN_TYPE" == "wireguard" ]]; then
            echo -e "    ${WHITE}1. Make sure your WireGuard Private Key is correct${NC}"
            echo -e "    ${WHITE}2. Verify your WireGuard Address matches the config${NC}"
            if [[ -n "$VPN_URL" ]]; then
                echo -e "    ${WHITE}3. Generate a new config from: ${CYAN}${VPN_URL}${NC}"
            else
                echo -e "    ${WHITE}3. Generate a new config from your ${VPN_NAME} account${NC}"
            fi
        else
            echo -e "    ${WHITE}1. Make sure you're using 'Service Credentials' from ${VPN_NAME}${NC}"
            echo -e "    ${WHITE}2. NOT your email/password login${NC}"
            if [[ -n "$VPN_URL" ]]; then
                echo -e "    ${WHITE}3. Get credentials from: ${CYAN}${VPN_URL}${NC}"
            else
                echo -e "    ${WHITE}3. Get credentials from your ${VPN_NAME} account${NC}"
            fi
        fi
        echo ""
        echo -e "  ${GRAY}To retry, run this script again.${NC}"
    fi
}

# Run
main
