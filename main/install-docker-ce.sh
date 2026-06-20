#!/usr/bin/env bash
# This Shell Script will install & configure Docker CE 
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
# Test Results:    ✓ Verified working
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
# Script Name:   install-docker-ce.sh
# Last Update:   14.06.2026
# Written by:    Praetoriani
# Website:       https://github.com/praetoriani
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆

# Load the WSL2 Library (important for this script)
CurrentScriptLocation="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"         # ← Gets the full path to the current location
source $CurrentScriptLocation/dockbay.lib.sh

# START WITH A CLEAN CONSOLE
clear

# Get the IP-Address of the WSL2/Debian Instance
HOST_IP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# THE FOLOWING SECTION IS A SET OF SCRIPT VARIABLES WHICH ARE USED TO CONFIGURE THE INSTALLATION OF THE DOCKER CONTAINER
CURRENT_USER=$(whoami)                              # This is the current user (who executed this script)
#------------------------------------------------------------------------------------------------------------------------------------------------------
# MAIN DOCKER CONFIGURATION
APP_FULL_NAME="Docker CE"                           # Full name of the App that will be installed (only used for console output)
APP_NAME="docker"                                   # The folder name of the App (do not use spaces! only use lowercase and - or _ )
APP_SERVICE="DockerCE"                              # The Name of the Service (Container Name) for the Compose File



# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# MANDATORY PRE-CHECKS

output_text "Script $0 started ..."
output_text "********************************************************************************"
output_null
output_text "Checking current configuration. Please wait ..."
output_null
sleep 0.5
# Get current config from global array and json
if [ "$(jq -r '.setup.dockertools' $SETUPCFGJSON)" = "false" ]; then
    output_text "Required Packages to install:  0"
    sleep 0.2
    output_text "Nothing to install."
    sleep 0.2
    output_text "Going back to Main Screen"
    output_null
    sleep 2.0
    exit 0
fi

# This part of the script will only be executed if there is anything to install
output_text "Required Docker Packages to be installed on your system:"
for pkg in "${DOCKER_PKGS[@]}"; do
    output_text "${RED_BOLD}→  $pkg ${DARK_GRAY_BOLD}"
    sleep 0.1
done
output_null
output_text "Please press '${WHITE_BOLD}c${DARK_GRAY_BOLD}' to continue or '${WHITE_BOLD}q${DARK_GRAY_BOLD}' to quit:"

set -euo pipefail
prompt="${DARK_GRAY_BOLD}→ ${NC}"
trap cleanup EXIT

while true; do
  # Print line and delete to end of line (\033[K)
  printf "\r\033[K%b" "$prompt"

  # Read a character without Enter and without echo
  IFS= read -r -n1 -s key

  case "$key" in
    q|Q)
        output_text "Returning back to Main Screen. Please wait ..."
        sleep 0.5
        clear
        exit 0
        ;;
    c|C)
        clear
        break
        ;;
    *)
        # Invalid input: flash briefly or simply rewrite the line
        # Optional: audible signal: printf '\a'
        # We simply rewrite the line (no additional output)
        continue
        ;;
  esac
done

# Install Docker Engine with following components:
# docker-ce – Docker Community Edition (the Daemon/Engine)
# docker-ce-cli – Docker Command Line Interface
# containerd.io – Container-Runtime
# docker-buildx-plugin – Extended Image-Building
# docker-compose-plugin – Docker Compose (as docker compose-command)
for pkg in "${DOCKER_PKGS[@]}"; do
    case "$pkg" in
        engine)
            # Remove old/invalid/conflicting Docker packages
            output_info "ℹ️ Removing old/invalid/conflicting Docker packages (if any)"
            sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-doc podman-docker containerd runc 2>/dev/null | cut -f1) 2>/dev/null || true
            output_okay "✅ Done."
            output_null

            # Install Dependencies and GPG Key
            output_info "ℹ️ Installing Dependencies and GPG Key"
            sudo apt update -y
            sudo apt install -y ca-certificates curl gnupg lsb-release
            output_okay "✅ Done."
            
            # Create directory for keyrings
            output_info "ℹ️ Creating directory for keyrings"
            sudo install -m 0755 -d /etc/apt/keyrings
            output_okay "✅ Done."

            # Download the official Docker GPG key.
            output_info "ℹ️ Downloading Docker GPG key"
            sudo curl -fsSL https://download.docker.com/linux/debian/gpg \
            -o /etc/apt/keyrings/docker.asc
            
            # Create Bookmark
            sudo chmod a+r /etc/apt/keyrings/docker.asc
            output_okay "✅ Done."
            output_null
            
            # Add Docker repository to APT
            output_info "ℹ️ Adding Docker repository to APT"
            sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
            sudo apt update -y
            output_okay "✅ Done."
            output_null

            output_info "ℹ️ Installing Docker Engine with required components"
            sudo apt install -y docker-ce docker-ce-cli containerd.io
            output_okay "✅ Done."
            output_null
            ;;
        compose)
            output_info "ℹ️ Installing Docker Compose Plugin"
            sudo apt install -y docker-compose-plugin
            output_okay "✅ Done."
            ;;
        buildx)
            output_info "ℹ️ Installing Docker Compose Plugin"
            sudo apt install -y docker-compose-plugin
            output_okay "✅ Done."
            ;;
    esac

    # Remove current Package from array
    local new_packages=()
    for p in "${DOCKER_PKGS[@]}"; do
        if [[ "$p" != "$pkg" ]]; then
            new_packages+=("$p")
        fi
    done
    DOCKER_PKGS=("${new_packages[@]}")
done

# Start and enable the Docker service.
output_info "ℹ️ Create Autostart, run Docker and show current status"
sudo systemctl enable docker   # Autostart on  Boot
sudo systemctl start docker    # Run Docker right now
sudo systemctl status docker   # check current status (shuld show "active (running)")
output_okay "✅ Done."
output_null


# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


# Create Docker-Group (if not already exists)
output_info "ℹ️ Creating Docker-Group (if not already exists)"
sudo groupadd docker 2>/dev/null || true && echo ""

# Add the current user to the Docker Group
output_info "ℹ️ Adding current user to Docker Group"
sudo usermod -aG docker $USER && echo ""

# Activate new group assignment (without restart)
output_info "ℹ️ Activating new group assignment"
newgrp docker && echo ""
output_okay "✅ Done."
output_null

# Ensure iptables compatibility (important for Debian in WSL2!)
output_info "ℹ️ Configuring iptables compatibility for Debian in WSL2"
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
output_okay "✅ Done."
output_null

# Configuring DNS for Docker Containers
output_info "ℹ️ Configuring DNS for Docker Containers"
if [ -f "/etc/resolv.conf" ]; then
    output_warn "⚠️ Old resolv.conf found! File will be renamed!"
    sudo mv /etc/resolv.conf /etc/resolv.conf.old
    output_okay "✅ Done."
    output_info "ℹ️ Creating new resolv.conf file now ..."
fi
cat << EOF > /etc/resolv.conf
# nameserver 10.255.255.254
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF
output_okay "✅ Done."
output_null

# Docker daemon configuration (daemon.json)
output_info "ℹ️ Configuring Docker daemon"
if [ -f "/etc/docker/daemon.json" ]; then
    output_warn "⚠️ Old daemon.json found! File will be removed and replaced with new config!"
    rm -f /etc/docker/daemon.json
    output_info "ℹ️ Creating new daemon.json file now ..."
fi
cat << EOF > /etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "dns": ["1.1.1.1", "8.8.8.8"],
  "live-restore": true
}
EOF
output_okay "✅ Done."
output_null

# Running RestartDockerDaemon from wsl2-lib.sh
RestartDockerDaemon

# Create Docker Network: db-cluster
output_info "ℹ️ Creating Docker Netwoks. Please wait ..."

if ! docker network ls --format '{{.Name}}' | grep -qx "system-core"; then
    # Create Docker Network: system-core
    output_info "ℹ️ Network: system-core"
    docker network create --driver bridge --attachable --subnet 172.22.0.0/16 --gateway 172.22.0.1 system-core
    # Verify that Network could be created
    if docker network inspect system-core >/dev/null 2>&1; then
        output_okay "✅ Successfully created."
        output_okay "   Subnet:     172.22.0.0/16"
        output_okay "   Gateway:    172.22.0.1"
        output_okay "   Broadcast:  172.22.255.255"
    else
        output_warn "⚠️ Failed creating Network!"
    fi
fi

if ! docker network ls --format '{{.Name}}' | grep -qx "apphost"; then
    # Create Docker Network: apphost
    output_info "ℹ️ Network: apphost"
    docker network create --driver bridge --attachable --subnet 172.24.0.0/16 --gateway 172.24.0.1 apphost
    # Verify that Network could be created
    if docker network inspect apphost >/dev/null 2>&1; then
        output_okay "✅ Successfully created."
        output_okay "   Subnet:     172.24.0.0/16"
        output_okay "   Gateway:    172.24.0.1"
        output_okay "   Broadcast:  172.24.255.255"
    else
        output_warn "⚠️ Failed creating Network!"
    fi
fi

if ! docker network ls --format '{{.Name}}' | grep -qx "db-cluster"; then
    # Create Docker Network: db-cluster
    output_info "ℹ️ Network: db-cluster"
    docker network create --driver bridge --attachable --subnet 172.30.0.0/16 --gateway 172.30.0.1 db-cluster
    # Verify that Network could be created
    if docker network inspect db-cluster >/dev/null 2>&1; then
        output_okay "✅ Successfully created."
        output_okay "   Subnet:     172.30.0.0/16"
        output_okay "   Gateway:    172.30.0.1"
        output_okay "   Broadcast:  172.30.255.255"
    else
        output_warn "⚠️ Failed creating Network!"
    fi
fi

if ! docker network ls --format '{{.Name}}' | grep -qx "db-cluster"; then
    # Create Docker Network: traefik-proxy
    output_info "ℹ️ Network: traefik-proxy"
    docker network create --driver bridge --attachable --subnet 172.40.0.0/16 --gateway 172.40.0.1 traefik-proxy
    # Verify that Network could be created
    if docker network inspect traefik-proxy >/dev/null 2>&1; then
        output_okay "✅ Successfully created."
        output_okay "   Subnet:     172.40.0.0/16"
        output_okay "   Gateway:    172.40.0.1"
        output_okay "   Broadcast:  172.40.255.255"
    else
        output_warn "⚠️ Failed creating Network!"
    fi
fi

cat << 'COMMENT' > /dev/null
# Create Docker Network: nginx-proxy
output_info "ℹ️ Network: nginx-proxy"
docker network create --driver bridge --attachable --subnet 172.50.0.0/16 --gateway 172.50.0.1 nginx-proxy
# Verify that Network could be created
if docker network inspect nginx-proxy >/dev/null 2>&1; then
    output_okay "✅ Successfully created."
    output_okay "   Subnet:     172.50.0.0/16"
    output_okay "   Gateway:    172.50.0.1"
    output_okay "   Broadcast:  172.50.255.255"
else
    output_warn "⚠️ Failed creating Network!"
fi
COMMENT

output_okay "✅ Done."
output_null

# Running RestartDockerDaemon from wsl2-lib.sh
RestartDockerDaemon

# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# MAIN SCRIPT FINISHED

output_info "ℹ️ Script$0 finished."
output_info "We recommend to reboot your system to fully apply all changes."
output_null
output_info "Enjoy using your ${APP_FULL_NAME} installation :)"
output_null
read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to return to Main Screen...\033[0m' && echo ""
output_text "$0 is exiting now ..."
output_null
clear
exit 0

