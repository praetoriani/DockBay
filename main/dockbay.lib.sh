#!/usr/bin/env bash
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
# Script Name:     dockbay.lib.sh
# Version:         v1.00.15
# Created on:      30.05.2026
# Last update:     19.06.2026
# Written by:      Praetoriani
# Website:         https://github.com/praetoriani
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
# Test Results:    ✓ Verified working
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
# This is a script library wich provides several usefull functions for linux bash scripts.
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆

# We need to make sure that we have at least Bash 4.0
if [ -z "${BASH_VERSINFO}" ] || [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    echo "Runtime error in $0 !" >&2
    echo "This script requires Bash 4.0 or higher!" >&2
    exit 1
fi

# ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
# → GLOBAL  🐳 DOCKBAY  CONFIGURATION

ScriptFullName="$(basename "${BASH_SOURCE[0]}")"                             # ← Gets the full script name 
ScriptFileName="${ScriptFullName%.*}"                                        # ← Remove the file extension
ScriptLocation="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"               # ← Gets the full path to the current location

MACHINE_NAME="$(hostname)"                                                   # ← Gets the current Hostname (name of the computer)
MACHINE_NAME="${MACHINE_NAME,,}"                                             # ← Convert it to lower cases (for certs etc.)
MACHINE_IPV4=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')   # ← Get the IPv4 of the current machine

SETUP_LOCATION="EMPTY"                                                       # ← Stores the Installation Location for the current script
DOCKBAY_PRECKECKS="false"                                                    # ← Stores is the PerformDockBayPrechecks-Function was performed or not

# ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
# → GLOBAL PATH CONFIGURATION

declare -A DOCKBAY                                                           # ← Stores all important paths
DOCKBAY["ROOTPATH"]="/opt/dockbay"                                           # ← Root Directory of DockBay
DOCKBAY["SYSSTACK"]="/opt/dockbay/core"                                      # ← For Docker-Related Apps
DOCKBAY["APPSTACK"]="/opt/dockbay/apps"                                      # ← For general/regulas apps
DOCKBAY["SQLSTACK"]="/opt/dockbay/dbhost"                                    # ← For Database Apps only!

#declare -A DOCKAPP                                                          # ← Stores all apps and their installation directory

REQUIRED_PKGS=(                                                              # ← Stores information about required Packages to be installed
    rsync
    libnss3-tools
    wget
    curl
    git
    openssl
    apache2-utils
    openssh-server
    pwgen
    jq
)

DOCKER_PKGS=(                                                               # ← Required to check whether Docker & Co is installed or not
    Engine
    Compose
    Buildx
)

DBCLUSTER_PKG=(
    MariaDB-Host
    PostgreSQL-Host
    MongoDB
    DBGate
)

APPCONTAINER=(
    BentoPDF
    BlinkoApp
    DBGate
    DockDploy
    Dockge
    Dockhand
    DockingStation
    Dockman
    Drawio
    DumbPad
    Etherpad
    Excalidraw
    Faved
    GlassKeep
    Grafana
    HedgeDocApp
    Homarr
    Homepage
    ITTools
    OmniTools
    Passbolt
    Planka
    PortainerCE
    portall
    PortCheckerIO
    Poznote
    PruneMate
    PasswordPush
    Sharkord
    TaskTrove
    Traefik
    UptimeKuma
    Vikunja
    xyOps
)

# ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

SETUPLOG="${DOCKBAY["ROOTPATH"]}/dockbay-setup.log"                         # ← Full path to the DockBay Setup Logfile
SETUPCFGJSON="${DOCKBAY["ROOTPATH"]}/setup.config.json"                     # ← Full path to the DockBay Setup Config JSON
SETUPTMPJSON="${DOCKBAY["ROOTPATH"]}/setup.config.temp"                     # ← Full path to the DockBay Setup Config TEMP JSON
DOCKBAYCONFIG="${DOCKBAY["ROOTPATH"]}/dockbay.config.json"                  # ← Full path to the DockBay Core Config JSON
DockBayScriptLocation=""

# ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

# Define color constants
# ============================================================
# Shell Color Constants
# ANSI 256-Color / xterm-256color
# ============================================================

# Reset / No Color
readonly NC=$'\033[0m'                           # No Color / Reset
# --- White / Black ---
readonly WHITE=$'\033[38;5;255m'                 # #EEEEEE
readonly WHITE_BOLD=$'\033[1;38;5;255m'          # #EEEEEE (BOLD)
readonly BLACK=$'\033[38;5;16m'                  # #000000
readonly BLACK_BOLD=$'\033[1;38;5;16m'           # #000000 (BOLD)
# --- Gray ---
readonly GRAY=$'\033[38;5;249m'                  # #BFBFBF
readonly GRAY_BOLD=$'\033[1;38;5;249m'           # #BFBFBF (BOLD)
readonly DARK_GRAY=$'\033[38;5;240m'             # #595959
readonly DARK_GRAY_BOLD=$'\033[1;38;5;240m'      # #595959 (BOLD)
# --- Red ---
readonly RED=$'\033[38;5;196m'                   # #E60000
readonly RED_BOLD=$'\033[1;38;5;196m'            # #E60000 (BOLD)
readonly RED_LIGHT=$'\033[38;5;203m'             # #FF3333
readonly RED_LIGHT_BOLD=$'\033[1;38;5;203m'      # #FF3333 (BOLD)
readonly RED_DARK=$'\033[38;5;160m'              # #B30000
readonly RED_DARK_BOLD=$'\033[1;38;5;160m'       # #B30000 (BOLD)
# --- Yellow ---
readonly YELLOW=$'\033[38;5;221m'                # #FFD11A
readonly YELLOW_BOLD=$'\033[1;38;5;221m'         # #FFD11A (BOLD)
readonly YELLOW_LIGHT=$'\033[38;5;222m'          # #FFE066
readonly YELLOW_LIGHT_BOLD=$'\033[1;38;5;222m'   # #FFE066 (BOLD)
readonly YELLOW_DARK=$'\033[38;5;220m'           # #E6B800
readonly YELLOW_DARK_BOLD=$'\033[1;38;5;220m'    # #E6B800 (BOLD)
# --- Orange ---
readonly ORANGE=$'\033[38;5;208m'                # #e67300
readonly ORANGE_BOLD=$'\033[1;38;5;208m'         # #e67300 (BOLD)
readonly ORANGE_LIGHT=$'\033[38;5;216m'          # #FF944D
readonly ORANGE_LIGHT_BOLD=$'\033[1;38;5;216m'   # #FF944D (BOLD)
readonly ORANGE_DARK=$'\033[38;5;166m'           # #e65c00
readonly ORANGE_DARK_BOLD=$'\033[1;38;5;166m'    # #e65c00 (BOLD)
# --- Green ---
readonly GREEN=$'\033[38;5;77m'                  # #33cc33
readonly GREEN_BOLD=$'\033[1;38;5;77m'           # #33cc33 (BOLD)
readonly GREEN_LIGHT=$'\033[38;5;120m'           # #4dff4d
readonly GREEN_LIGHT_BOLD=$'\033[1;38;5;120m'    # #4dff4d (BOLD)
readonly GREEN_DARK=$'\033[38;5;71m'             # #2d862d
readonly GREEN_DARK_BOLD=$'\033[1;38;5;71m'      # #2d862d (BOLD)
# --- Blue ---
readonly BLUE=$'\033[38;5;39m'                   # #0099ff
readonly BLUE_BOLD=$'\033[1;38;5;39m'            # #0099ff (BOLD)
readonly BLUE_LIGHT=$'\033[38;5;117m'            # #4db8ff
readonly BLUE_LIGHT_BOLD=$'\033[1;38;5;117m'     # #4db8ff (BOLD)
readonly BLUE_DARK=$'\033[38;5;32m'              # #007acc
readonly BLUE_DARK_BOLD=$'\033[1;38;5;32m'       # #007acc (BOLD)
# --- Cyan ---
readonly CYAN=$'\033[38;5;51m'                   # #00ffff
readonly CYAN_BOLD=$'\033[1;38;5;51m'            # #00ffff (BOLD)
readonly CYAN_LIGHT=$'\033[38;5;159m'            # #80ffff
readonly CYAN_LIGHT_BOLD=$'\033[1;38;5;159m'     # #80ffff (BOLD)
readonly CYAN_DARK=$'\033[38;5;44m'              # #00cccc
readonly CYAN_DARK_BOLD=$'\033[1;38;5;44m'       # #00cccc (BOLD)
# --- Magenta ---
readonly MAGENTA=$'\033[38;5;199m'               # #ff0080
readonly MAGENTA_BOLD=$'\033[1;38;5;199m'        # #ff0080 (BOLD)
readonly MAGENTA_LIGHT=$'\033[38;5;211m'         # #ff4da6
readonly MAGENTA_LIGHT_BOLD=$'\033[1;38;5;211m'  # #ff4da6 (BOLD)
readonly MAGENTA_DARK=$'\033[38;5;162m'          # #cc0066
readonly MAGENTA_DARK_BOLD=$'\033[1;38;5;162m'   # #cc0066 (BOLD)
# --- Purple ---
readonly PURPLE=$'\033[38;5;129m'                # #8000ff
readonly PURPLE_BOLD=$'\033[1;38;5;129m'         # #8000ff (BOLD)
readonly PURPLE_LIGHT=$'\033[38;5;135m'          # #9933ff
readonly PURPLE_LIGHT_BOLD=$'\033[1;38;5;135m'   # #9933ff (BOLD)
readonly PURPLE_DARK=$'\033[38;5;92m'            # #6600cc
readonly PURPLE_DARK_BOLD=$'\033[1;38;5;92m'     # #6600cc (BOLD)



# Professional logging functions
output_null()   { echo -e ""; }
output_text()   { echo -e "${DARK_GRAY_BOLD}$*${NC}"; }
output_info()   { echo -e "${BLUE_BOLD}$*${NC}"; }
output_warn()   { echo -e "${ORANGE_BOLD}$*${NC}"; }
output_fail()   { echo -e "${RED_BOLD}$*${NC}"; }
output_okay()   { echo -e "${GREEN_BOLD}$*${NC}"; }
output_note()   { echo -e "${PURPLE_LIGHT_BOLD}$*${NC}"; }
output_debug()  { echo -e "${YELLOW_DARK_BOLD}$*${NC}"; }
output_code()   { echo -e "$*"; }

# Small Helper-Function to reset the terminal
cleanup() {
  stty sane
  printf "\n"
}


# ----- Function → SetupLocationConfig --------------------------------------------------
# This function sets the Setup Location for each Docker Container
# based on the type/kind of App the Docker Container includes.
SetupLocationConfig() {
    # Get the passed argument
    local apptype="$1"

    # Verify that the argument isn't empty
    if [ -z "${apptype}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   'apptype' is empty or not defined!"
        output_warn "   Usage: ${FUNCNAME} <APPTYPE>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi

    if [ "$apptype" = "app" ] || [ "$apptype" = "APP" ]; then
        SETUP_LOCATION="${DOCKBAY["APPSTACK"]}"
        return 0
    elif [ "$apptype" = "sys" ] || [ "$apptype" = "SYS" ]; then
        SETUP_LOCATION="${DOCKBAY["SYSSTACK"]}"
        return 0
    elif [ "$apptype" = "sql" ] || [ "$apptype" = "SQL" ]; then
        SETUP_LOCATION="${DOCKBAY["SQLSTACK"]}"
        return 0
    else
        SETUP_LOCATION="EMPTY"
        return 1
    fi

}


# ----- Function → CheckPackage ---------------------------------------------------------
# This function checks whether a package is installed/available on the host or not
CheckPackage() {
    local pkg="$1"
    # Verify that the argument isn't empty
    if [ -z "${pkg}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   'pkg' is empty or not defined!"
        output_warn "   Usage: ${FUNCNAME} <PKG>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi

    output_text "Checking if  '$pkg'  is installed on your system ..."
    sleep 0.1
    if dpkg -s "$pkg" >/dev/null 2>&1; then
        output_text "${GREEN_BOLD}[ ✓ ]${DARK_GRAY_BOLD}  '$pkg'  is installed"
        sleep 0.1
        # Remove 'pkg' fro array REQUIRED_PKGS
        local new_packages=()
        for p in "${REQUIRED_PKGS[@]}"; do
            if [[ "$p" != "$pkg" ]]; then
                new_packages+=("$p")
            fi
        done
        REQUIRED_PKGS=("${new_packages[@]}")
        return 0
    else
        output_text "${RED_BOLD}[ × ]${DARK_GRAY_BOLD}  '$pkg'  is not installed"
        sleep 0.1
        return 1
    fi
}


# ----- Function → ShowRequiredPKG ------------------------------------------------------
ShowRequiredPKG() {

    if [ ${#REQUIRED_PKGS[@]} -eq 0 ]; then
        output_text "Reuired Packages to be installed on your system:  0"
    else
        output_text "Reuired Packages to be installed on your system:"
        for pkg in "${REQUIRED_PKGS[@]}"; do
            output_text "${RED_BOLD}→  $pkg ${DARK_GRAY_BOLD}"
        done
    fi
    return 0    
}


# ----- Function → CheckDocker ----------------------------------------------------------
CheckDocker() {
    # Get the passed argument and convert it to lowwer case
    local pkg="$1"

    # Verify that the argument isn't empty
    if [ -z "${pkg}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   'pkg' is empty or not defined!"
        output_warn "   Usage: ${FUNCNAME} <PKG>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi

    output_text "Checking if  'Docker $pkg'  is installed on your system ..."
    sleep 0.1
    local found="false"
    if [ "${pkg,,}" = "engine" ] || [ "${pkg,,}" = "compose" ] || [ "${pkg,,}" = "buildx" ]; then
        
        case "${pkg,,}" in
            engine)
                if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
                    found="true"
                    output_text "${GREEN_BOLD}[ ✓ ]${DARK_GRAY_BOLD}  'Docker $pkg'  is installed"
                    sleep 0.1
                else
                    output_text "${RED_BOLD}[ × ]${DARK_GRAY_BOLD}  'Docker $pkg'  is not installed"
                    sleep 0.1
                fi
                ;;
            compose)
                if docker compose version >/dev/null 2>&1; then
                    found="true"
                    output_text "${GREEN_BOLD}[ ✓ ]${DARK_GRAY_BOLD}  'Docker $pkg'  is installed"
                    sleep 0.1
                else
                    output_text "${RED_BOLD}[ × ]${DARK_GRAY_BOLD}  'Docker $pkg'  is not installed"
                    sleep 0.1
                fi
                ;;
            buildx)
                if docker buildx version >/dev/null 2>&1; then
                    found="true"
                    output_text "${GREEN_BOLD}[ ✓ ]${DARK_GRAY_BOLD}  'Docker $pkg'  is installed"
                    sleep 0.1
                else
                    output_text "${RED_BOLD}[ × ]${DARK_GRAY_BOLD}  'Docker $pkg'  is not installed"
                    sleep 0.1
                fi
                ;;
        esac

        if [ "${found,,}" = "true" ]; then
            # Remove 'pkg' from array
            local new_packages=()
            for p in "${DOCKER_PKGS[@]}"; do
                if [[ "$p" != "$pkg" ]]; then
                    new_packages+=("$p")
                fi
            done
            DOCKER_PKGS=("${new_packages[@]}")
        fi
        return 0
    else
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   '$pkg' in an invalid value for 'pkg'!"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi

}


# ----- Function → CheckContainer -------------------------------------------------------
#iscontainer=$(CheckContainer "ContainerName")
#if [ "$(CheckContainer "ContainerName")" = "ok" ]; then
#    echo "ContainerName exists."
#else
#    echo "ContainerName not found."
#fi
CheckContainer() {
    # Get the passed argument
    local container="$1"
    # Verify that the argument isn't empty
    if [ -z "${container}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   Argument 'container' is not defined!"
        output_warn "   Usage: ${FUNCNAME} <container>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi
    # Check if the given docker container exsists
    if docker inspect "$container" >/dev/null 2>&1; then
        echo "ok"
        return 0
    else
        echo "xx"
        return 1
    fi
}


# ----- Function → ContainerStatus ------------------------------------------------------
#iscontainer=$(ContainerStatus "ContainerName")
#if [ "$(ContainerStatus "ContainerName")" = "ok" ]; then
#    echo "ContainerName is running."
#else
#    echo "ContainerName not running."
#fi
ContainerStatus() {
    # Get the passed argument
    local container="$1"
    # Verify that the argument isn't empty
    if [ -z "${container}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   Argument 'container' is not defined!"
        output_warn "   Usage: ${FUNCNAME} <container>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi
    # Get the status of the given container
    STATUS=$(docker inspect --format '{{.State.Status}}' "$container")
    # Check if the given docker container exsists
    if [ "$STATUS" = "running" ]; then
        echo "ok"
        return 0
    else
        echo "xx"
        return 1
    fi
}


# ----- Function → ReturnContainerInfo --------------------------------------------------
#if [ "$(ReturnContainerInfo "check" "ContainerName")" = "found" ]; then
#    echo "ContainerName found."
#else
#    echo "ContainerName not found."
#fi
#if [ "$(ReturnContainerInfo "status" "ContainerName")" = "running" ]; then
#    echo "ContainerName is currently running"
#else
#    echo "ContainerName is not running at the moment."
#fi
ReturnContainerInfo() {
    # Get the passed arguments
    local switch="$1"
    local container="$2"
    # Verify that the argument isn't empty
    if [ -z "${switch}" ] || [ -z "${container}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   At least one mandatory argument is missing!"
        output_warn "   Usage: ${FUNCNAME} <switch> <container>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi

    if [ "${switch,,}" = "check" ]; then
        if [ "$(CheckContainer "$container")" = "ok" ]; then
            echo "found"
            return 0
        else
            echo "not found"
            return 1
        fi
    fi

    if [ "${switch,,}" = "status" ]; then
        if [ "$(ContainerStatus "$container")" = "ok" ]; then
            echo "${GREEN_BOLD}running${DARK_GRAY_BOLD}"
            return 0
        elif [ "$(ContainerStatus "$container")" = "xx" ]; then
            echo "${RED_BOLD}not running${DARK_GRAY_BOLD}"
            return 1
        else
            echo "unknown"
            return 1
        fi
    fi
    
    output_warn "⚠️ Error in function:  ${FUNCNAME}"
    output_warn "   $switch is an invalid argument for 'switch'!"
    output_warn "   Usage: ${FUNCNAME} <switch> <container>"
    output_warn "---------------------------------------------------------------------------"
    output_warn "${FUNCNAME} will be terminated prematurely!"
    output_null
    read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
    exit 1
}


# ----- Function → CheckDBCluster -------------------------------------------------------
CheckDBCluster() {
    # Get the passed argument
    local container="$1"
    # Verify that the argument isn't empty
    if [ -z "${container}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   Argument 'container' is not defined!"
        output_warn "   Usage: ${FUNCNAME} <container>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi

    local EXISTS="$(CheckContainer "$container")"
    local STATUS="$(ContainerStatus "$container")"

    output_text "Checking for Docker Container:  $container"
    sleep 0.1
    if [ "$EXISTS" = "ok" ]; then
        if [ "$STATUS" = "ok" ]; then
            output_text "${GREEN_BOLD}[ ✓ ]${DARK_GRAY_BOLD}  Container found.     Status:  ${GREEN_BOLD}running${DARK_GRAY_BOLD}"
        else
            output_text "${GREEN_BOLD}[ ✓ ]${DARK_GRAY_BOLD}  Container found.     Status:  ${RED_BOLD}not running${DARK_GRAY_BOLD}"
        fi
        # Remove 'pkg' from array
        local new_packages=()
        for p in "${DBCLUSTER_PKG[@]}"; do
            if [[ "$p" != "$pkg" ]]; then
                new_packages+=("$p")
            fi
        done
        DBCLUSTER_PKG=("${new_packages[@]}")
        # update the setup.config.json
        case "${container,,}" in
            mariadb-host)
                jq '.setup.msqldbhost = false' $SETUPCFGJSON > $SETUPTMPJSON && mv $SETUPTMPJSON $SETUPCFGJSON
                ;;
            postgresql-host)
                jq '.setup.psqldbhost = false' $SETUPCFGJSON > $SETUPTMPJSON && mv $SETUPTMPJSON $SETUPCFGJSON
                ;;
            mongodb)
                jq '.setup.mongodbhost = false' $SETUPCFGJSON > $SETUPTMPJSON && mv $SETUPTMPJSON $SETUPCFGJSON
                ;;
            dbgate)
                jq '.app.DBGate = false' $SETUPCFGJSON > $SETUPTMPJSON && mv $SETUPTMPJSON $SETUPCFGJSON
                ;;
        esac
    else
        output_text "${RED_BOLD}[ × ]${DARK_GRAY_BOLD}  Container not found.  Status:  not available"
    fi
    sleep 0.1
    return 0
}


# ----- Function → ScanDockBayContainer -------------------------------------------------
# This function scans for already existing App Containers and updates the
# setup.config.json based on the Test-Results
ScanDockBayContainer() {
    # Get the passed argument
    local container="$1"
    # Verify that the argument isn't empty
    if [ -z "${container}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   Argument 'container' is not defined!"
        output_warn "   Usage: ${FUNCNAME} <container>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi

    output_text "Checking for Docker Container:  $container"
    sleep 0.1

    # Check if the given Docker Container exists (based on the Container Name)
    if [ "$(CheckContainer "$container")" = "ok" ]; then
        output_text "${GREEN_BOLD}[ ✓ ]${DARK_GRAY_BOLD}  Container found."
        sleep 0.1
        # Container was found → update the setup.config.json
        # Note: Due to we can trust the caller, we can use the passed name to update the json file
        jq ".app.$container = false" $SETUPCFGJSON > $SETUPTMPJSON && mv $SETUPTMPJSON $SETUPCFGJSON
    else
        output_text "${RED_BOLD}[ × ]${DARK_GRAY_BOLD}  Container not found."
        sleep 0.1
        # Container was not found → update the setup.config.json
        # Note: Due to we can trust the caller, we can use the passed name to update the json file
        jq ".app.$container = true" $SETUPCFGJSON > $SETUPTMPJSON && mv $SETUPTMPJSON $SETUPCFGJSON
    fi
    sleep 0.1
    return 0
}


# ----- Function → PrintSetupScreen -----------------------------------------------------
# Usage:   PrintSetupScreen "1"
PrintSetupScreen() {
    # Get the passed argument
    local page="$1"

    # Verify that the argument isn't empty
    if [ -z "${page}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   Mandatory param 'page' is missing!"
        output_warn "   Usage: ${FUNCNAME} <PAGE>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi

    if [ "$page" = "1" ]; then
        #output_text "DOCKBAY  INSTALLER  PAGE  NO  01"
        output_text "********************************************************************************"
        output_null
        output_text "                         Welcome to  🐳 DockBay  Setup                         "
        output_null
        output_text "This Installation Script will help you to set up a complete Docker Environment"
        output_text "on your system from scratch. Just follow the instructions on the screen."
        output_null
        output_text "Visit  http://github.com/praetoriani  for more information about the Project :)"
        output_null
        output_text "💡 Please note:"
        output_text "This screen only appears once. So we recommend to read the text on this page."
        output_null
        output_text "The Installation Process is split up into multiple parts. Based on the results"
        output_text "from the previous system check, the Main Screen will clearly show you, what you"
        output_text "have to do next."
        output_null
        output_text "The absolute minimum installation requires you to run through the installation"
        output_text "steps 1 to 3 on the next screen, till you can see a ${GREEN_BOLD}✓${DARK_GRAY_BOLD} Sign behind each step."
        output_text "The 4th step (Traefik Proxy) is optional but recommended. All Docker Containers"
        output_text "will work without this step. But they will NOT be accessible via Traefik URLs!"
        output_null
        output_text "There is one thing you should know about the included Docker Containers inside"
        output_text "the 🐳 DockBay Project. These Containers ONLY work inside 🐳 DockBay Project!"
        output_null
        output_fail "🛡️ Security Advice:"
        output_fail "‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"
        output_fail "The entire 🐳 DockBay Envirnoment uses numerous default configurations for"
        output_fail "user accounts and passwords! During installation (where applicable) you have"
        output_fail "two Options. You can either use the default settings (not recommended) or"
        output_fail "set your own login credentials during installation (recommended way)."
        output_null
        output_text "But enough said for now. Let's start with the setup :)"
        output_null
        output_text "********************************************************************************"
        return 0
    elif [ "$page" = "2" ]; then
        #output_text "DOCKBAY  INSTALLER  PAGE  NO  02"
        output_text "********************************************************************************"
        output_null
        output_text "                         Main  🐳 DockBay  Setup"
        output_null
        output_text "This is the Main Screen of the Installer. Below you can see all Options"
        output_text "of this Installation Script. Choose one of the following options:"
        output_null
        if [ "$(jq -r '.setup.systemtools' $SETUPCFGJSON)" = "true" ]; then
        output_text "     1.  Install System Tools (required)                         [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "     1.  Install System Tools (required)                         [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]"
        fi
        if [ "$(jq -r '.setup.dockertools' $SETUPCFGJSON)" = "true" ]; then
        output_text "     2.  Install Docker CE (Engine,Compose,Buildx)               [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "     2.  Install Docker CE (Engine,Compose,Buildx)               [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]"
        fi
        local checkmariadb="$(jq -r '.setup.msqldbhost' $SETUPCFGJSON)"
        local checkpostgre="$(jq -r '.setup.psqldbhost' $SETUPCFGJSON)"
        local checkmongodb="$(jq -r '.setup.mongodbhost' $SETUPCFGJSON)"
        local checkdbgate="$(jq -r '.app.DBGate' $SETUPCFGJSON)"
        if [ "$checkmariadb" = "false" ] && [ "$checkpostgre" = "false" ] && [ "$checkmongodb" = "false" ] && [ "$checkdbgate" = "false" ]; then
        output_text "     3.  Install DB Cluster (MariaDB, PostgeSQL)                 [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]"
        else
        output_text "     3.  Install DB Cluster (MariaDB, PostgeSQL)                 [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        fi
        if [ "$(jq -r '.setup.traefikproxy' $SETUPCFGJSON)" = "true" ]; then
        output_text "     4.  Install Traefik Reverse Proxy                           [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "     4.  Install Traefik Reverse Proxy                           [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]"
        fi
        output_text "     5.  Install additional Docker Containers                    [${BLUE_LIGHT_BOLD}?${DARK_GRAY_BOLD}]"
        output_null
        output_null
        output_null
        output_text "→ A  ${RED_BOLD}×${DARK_GRAY_BOLD}  indicates, that you must run this option!"
        output_text "→ A  ${GREEN_BOLD}✓${DARK_GRAY_BOLD}  indicates, that this option can be skipped."
        output_null
        output_text "→ The  ${BLUE_LIGHT_BOLD}?${DARK_GRAY_BOLD}  indicates that we didn't scan for installed containers yet"
        output_text "  You will see a scan summary on the Setup Page of the 5 installation step."
        output_null
        output_text "Please Note:"
        output_text "Each Installation Step (1 to 5) will take you to another page where the"
        output_text "selected components will be installed (and in some cases also configured)."
        output_text "After the Installation has finished, you will automatically come back here"
        output_text "to this Main Installation Screen which will be updated according to the"
        output_text "results of the installation. This page will always show you, which steps"
        output_text "you still have to take, before you can install any Docker Containers."
        output_null
        output_text "Every single Installation Step (Step 1 excluded) requires the previous Step"
        output_text "to finish successfully. You have to run the Setup Steps in correct order."
        output_null
        output_text "********************************************************************************"
        return 0
    elif [ "$page" = "3" ]; then
        output_text "********************************************************************************"
        output_null
        output_text "                   🐳 DockBay  Container Setup Management"
        output_null
        output_text "On this page you can see a list of all available Docker Containers you can add"
        output_text "to your current DockBay Environment. Just enter the number of the desired"
        output_text "Container you want to add and let the script do the rest for you :)"
        output_null

        if [ "$(jq -r '.app.BentoPDF' $SETUPCFGJSON)" = "true" ]; then
        output_text "   01.  BentoPDF               [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   01.  BentoPDF               [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.BlinkoApp' $SETUPCFGJSON)" = "true" ]; then
        output_text "   02.  Blinko                 [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   02.  Blinko                 [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.DockDploy' $SETUPCFGJSON)" = "true" ]; then
        output_text "   03.  Dock-Dploy             [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   03.  Dock-Dploy             [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.Dockge' $SETUPCFGJSON)" = "true" ]; then
        output_text "   04.  Dockge                 [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   04.  Dockge                 [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.Dockhand' $SETUPCFGJSON)" = "true" ]; then
        output_text "   05.  Dockhand               [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   05.  Dockhand               [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.DockingStation' $SETUPCFGJSON)" = "true" ]; then
        output_text "   06.  Dockingstation         [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   06.  Dockingstation         [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.Dockman' $SETUPCFGJSON)" = "true" ]; then
        output_text "   07.  Dockman                [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   07.  Dockman                [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.Drawio' $SETUPCFGJSON)" = "true" ]; then
        output_text "   08.  Draw.io                [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   08.  Draw.io                [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.DumbPad' $SETUPCFGJSON)" = "true" ]; then
        output_text "   09.  Dumbpad                [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   09.  Dumbpad                [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.Etherpad' $SETUPCFGJSON)" = "true" ]; then
        output_text "   10.  Etherpad               [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   10.  Etherpad               [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.Excalidraw' $SETUPCFGJSON)" = "true" ]; then
        output_text "   11.  Excalidraw             [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   11.  Excalidraw             [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.Faved' $SETUPCFGJSON)" = "true" ]; then
        output_text "   12.  Faved                  [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   12.  Faved                  [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.GlassKeep' $SETUPCFGJSON)" = "true" ]; then
        output_text "   13.  Glasskeep              [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   13.  Glasskeep              [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.Grafana' $SETUPCFGJSON)" = "true" ]; then
        output_text "   14.  Grafana                [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   14.  Grafana                [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.HedgeDocApp' $SETUPCFGJSON)" = "true" ]; then
        output_text "   15.  Hedgedoc               [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   15.  Hedgedoc               [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.Homarr' $SETUPCFGJSON)" = "true" ]; then
        output_text "   16.  Homarr                 [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   16.  Homarr                 [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.Homepage' $SETUPCFGJSON)" = "true" ]; then
        output_text "   17.  Homepage               [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   17.  Homepage               [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.ITTools' $SETUPCFGJSON)" = "true" ]; then
        output_text "   18.  IT-Tools               [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   18.  IT-Tools               [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.OmniTools' $SETUPCFGJSON)" = "true" ]; then
        output_text "   19.  Omni-Tools             [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   19.  Omni-Tools             [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.Passbolt' $SETUPCFGJSON)" = "true" ]; then
        output_text "   20.  Passbolt               [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   20.  Passbolt               [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.Planka' $SETUPCFGJSON)" = "true" ]; then
        output_text "   21.  Planka                 [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   21.  Planka                 [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.PortainerCE' $SETUPCFGJSON)" = "true" ]; then
        output_text "   22.  Portainer              [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   22.  Portainer              [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.portall' $SETUPCFGJSON)" = "true" ]; then
        output_text "   23.  Portall                [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   23.  Portall                [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.PortCheckerIO' $SETUPCFGJSON)" = "true" ]; then
        output_text "   24.  Portchecker            [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   24.  Portchecker            [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.Poznote' $SETUPCFGJSON)" = "true" ]; then
        output_text "   25.  Poznote                [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   25.  Poznote                [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.PruneMate' $SETUPCFGJSON)" = "true" ]; then
        output_text "   26.  Prunemate              [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   26.  Prunemate              [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.PasswordPush' $SETUPCFGJSON)" = "true" ]; then
        output_text "   27.  Password Push          [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   27.  Password Push          [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.Sharkord' $SETUPCFGJSON)" = "true" ]; then
        output_text "   28.  Sharkord Chat          [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   28.  Sharkord Chat          [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.TaskTrove' $SETUPCFGJSON)" = "true" ]; then
        output_text "   29.  Tasktrove              [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   29.  Tasktrove              [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.UptimeKuma' $SETUPCFGJSON)" = "true" ]; then
        output_text "   30.  Uptime Kuma            [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   30.  Uptime Kuma            [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.Vikunja' $SETUPCFGJSON)" = "true" ]; then
        output_text "   31.  Vikunja                [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   31.  Vikunja                [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        
        if [ "$(jq -r '.app.xyOps' $SETUPCFGJSON)" = "true" ]; then
        output_text "   32.  xyOps                  [${RED_BOLD}×${DARK_GRAY_BOLD}]"
        else
        output_text "   32.  xyOps                  [${GREEN_BOLD}✓${DARK_GRAY_BOLD}]          Current Status: $(ReturnContainerInfo "status" "BentoPDF")"
        fi        
        output_null
        output_null
        output_text "→ A  ${RED_BOLD}×${DARK_GRAY_BOLD}  indicates, that this Container does not exist and can be added."
        output_text "→ A  ${GREEN_BOLD}✓${DARK_GRAY_BOLD}  indicates, that this Container already exists."
        output_null
        return 0
    else
        output_fail "🛑 Error in function:  ${FUNCNAME}"
        output_fail "   'page' has invalid value! Page '$page' does not exist!"
        output_fail "---------------------------------------------------------------------------"
        output_fail "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi

}


# ----- Function → WriteLogfile ---------------------------------------------------------
# Usage:  WriteLogfile "/path/to/file.txt" "My new text" "Y"
WriteLogfile() {

    # Get the passed argument
    local file="$1"
    local text="$2"
    local create="${3:-N}"

    # Verify that the argument isn't empty
    if [ -z "${file}" ] || [ -z "${text}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   One or more mandatory params missing!"
        output_warn "   Usage: ${FUNCNAME} <FILE> <TEXT> <CREATE>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi

    timestamp="[ $(date '+%d.%m.%Y ; %H:%M:%S') ]"
    checkfile=$(FileLookup $file)
    if [ "$checkfile" = "ok" ]; then
        #printf "%s\n" $text | sudo tee -a $file > /dev/null
        #echo "$text" | sudo tee -a "$file"
        echo "$timestamp   $text" >> "$file"
        return 0
    else
        if [ "$create" = "y" ] || [ "$create" = "Y" ]; then
            #printf "%s\n" $text | sudo tee -a $file > /dev/null
            echo "$timestamp   $text" >> "$file"
            return 0
        fi
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   $file does not exist!"
        output_warn "   Unable to create and/or write to file!"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi
}


# ----- Function → WriteToFile ----------------------------------------------------------
# Usage:  WriteToFile "/path/to/file.txt" "My new text" "Y"
WriteToFile() {

    # Get the passed argument
    local file="$1"
    local text="$2"
    local create="${3:-N}"

    # Verify that the argument isn't empty
    if [ -z "${file}" ] || [ -z "${text}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   One or more mandatory params missing!"
        output_warn "   Usage: ${FUNCNAME} <FILE> <TEXT> <CREATE>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi

    checkfile=$(FileLookup $file)
    if [ "$checkfile" = "ok" ]; then
        #printf "%s\n" $text | sudo tee -a $file > /dev/null
        #echo "$text" | sudo tee -a "$file"
        echo "$text" >> "$file"
        return 0
    else
        if [ "$create" = "y" ] || [ "$create" = "Y" ]; then
            #printf "%s\n" $text | sudo tee -a $file > /dev/null
            echo "$text" > "$file"
            return 0
        fi
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   $file does not exist!"
        output_warn "   Unable to create and/or write to file!"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi
}


# ----- Function → DockerInstallCheck ----------------------------------------------------
# This function simply checks, if Docker CE is installed or not
DockerInstallCheck() {
    output_info "ℹ️ Checking if Docker CE is installed on your system. Please wait ..."
    # Check if Docker is installed
    if ! command -v docker >/dev/null 2>&1; then
        output_okay "✅ Docker CE is currently not installed."
    else
        output_warn "⚠️ Docker CE installation found."
        output_warn "   Installation of Docker CE is not required!"
    fi
    output_null
    output_info "ℹ️ Checking if Docker Daemon on your System. Please wait ..."
    # Is Docker Daemon running and reachable?
    if ! docker info >/dev/null 2>&1; then
        output_okay "✅ No Docker Daemon found on your system."
    else
        output_warn "⚠️ Docker Daemon found on your system."
        output_warn "   Installation of Docker CE is not required!"
    fi
    output_null
    output_info "ℹ️ Checking if Docker Compose v2 is installed. Please wait ..."
    # Check if Compose v2 (docker compose) is installed
    if ! docker compose version >/dev/null 2>&1; then
        output_okay "✅ Docker Compose v2 is not installed."
    else
        output_warn "⚠️ Docker Compose v2 is already installed."
        output_warn "   Installation of Docker CE is not required!"
    fi
    output_null
}


# ----- Function → DockerSystemPrecheck --------------------------------------------------
# This function performs several prechecks to make sure that all requirements are met
DockerSystemPrecheck() {
    output_info "ℹ️ Performing mandatory Pre-Checks. Please wait ..."
    output_info "ℹ️ Checking if Docker CE is installed ..."
    # Check if Docker is installed
    if ! command -v docker >/dev/null 2>&1; then
        output_fail "🛑 Docker CE is not installed on this System!"
        output_fail "   Script ${ScriptFullName} exiting ... "
        output_fail "---------------------------------------------------------------------------"
        output_text "Please install Docker CE first."
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    else
        output_okay "✅ Docker CE installation found."
    fi
    output_null

    output_info "ℹ️ Checking if Docker Daemon is running and reachable ..."
    # Is Docker Daemon running and reachable?
    if ! docker info >/dev/null 2>&1; then
        output_fail "🛑 Docker Daemon is not running or not reachable!"
        output_fail "   Script ${ScriptFullName} exiting ... "
        output_fail "---------------------------------------------------------------------------"
        output_text "Please start Docker Daemon."
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 2
    else
        output_okay "✅ Docker Daemon is running and reachable."
    fi
    output_null

    output_info "ℹ️ Checking if Docker Compose v2 is installed ..."
    # Check if Compose v2 (docker compose) is installed
    if ! docker compose version >/dev/null 2>&1; then
        output_fail "🛑 Docker Compose v2 (docker compose) is not installed!"
        output_fail "   Script ${ScriptFullName} exiting ... "
        output_fail "---------------------------------------------------------------------------"
        output_text "Please install Docker Compose v2."
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    else
        output_okay "✅ Docker Compose v2 installation found."
    fi
    output_null
}


# ----- Function → DockerNetworkPrecheck -------------------------------------------------
# This function performs several Docker Network Checks
# to make sure that all required Docker Networks exist
DockerNetworkPrecheck () {
    output_info "ℹ️ Performing Docker Network Checks. Please wait ..."
    output_info "ℹ️ Checking if Docker-Network 'system-core' already exists ..."
    # Check if system-core network exists
    if ! docker network inspect system-core > /dev/null 2>&1; then
        output_fail "🛑 Docker Network 'system-core' does not exist!"
        output_fail "  Installation will be cancelled."
        output_fail "  Script ${ScriptFullName} exiting ... "
        output_fail "---------------------------------------------------------------------------"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    else
        output_okay "✅ Docker-Network 'system-core' found."
        output_okay "   $(docker network inspect system-core --format 'Subnet:   {{(index .IPAM.Config 0).Subnet}}{{"\n"}}   Gateway:  {{(index .IPAM.Config 0).Gateway}}')"
    fi
    output_null

    output_info "ℹ️ Checking if Docker-Network 'db-cluster' already exists ..."
    # Check if db-cluster network exists
    if ! docker network inspect db-cluster > /dev/null 2>&1; then
        output_fail "🛑 Docker Network 'db-cluster' does not exist!"
        output_fail "  Installation will be cancelled."
        output_fail "  Script ${ScriptFullName} exiting ... "
        output_fail "---------------------------------------------------------------------------"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    else
        output_okay "✅ Docker-Network 'db-cluster' found."
        output_okay "   $(docker network inspect db-cluster --format 'Subnet:   {{(index .IPAM.Config 0).Subnet}}{{"\n"}}   Gateway:  {{(index .IPAM.Config 0).Gateway}}')"
    fi
    output_null

    output_info "ℹ️ Checking if Docker-Network 'apphost' already exists ..."
    # Check if apphost network exists
    if ! docker network inspect apphost > /dev/null 2>&1; then
        output_fail "🛑 Docker Network 'apphost' does not exist!"
        output_fail "  Installation will be cancelled."
        output_fail "  Script ${ScriptFullName} exiting ... "
        output_fail "---------------------------------------------------------------------------"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    else
        output_okay "✅ Docker-Network 'apphost' found."
        output_okay "   $(docker network inspect apphost --format 'Subnet:   {{(index .IPAM.Config 0).Subnet}}{{"\n"}}   Gateway:  {{(index .IPAM.Config 0).Gateway}}')"
    fi
    output_null

    output_info "ℹ️ Checking if Docker-Network 'traefik-proxy' already exists ..."
    # Check if traefik-proxy network exists
    if ! docker network inspect traefik-proxy > /dev/null 2>&1; then
        output_fail "🛑 Docker Network 'traefik-proxy' does not exist!"
        output_fail "  Installation will be cancelled."
        output_fail "  Script ${ScriptFullName} exiting ... "
        output_fail "---------------------------------------------------------------------------"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    else
        output_okay "✅ Docker-Network 'traefik-proxy' found."
        output_okay "   $(docker network inspect traefik-proxy --format 'Subnet:   {{(index .IPAM.Config 0).Subnet}}{{"\n"}}   Gateway:  {{(index .IPAM.Config 0).Gateway}}')"
    fi
    output_null

cat << 'COMMENT' > /dev/null
    output_info "ℹ️ Checking if Docker-Network 'nginx-proxy' already exists ..."
    # Check if nginx-proxy network exists
    if ! docker network inspect nginx-proxy > /dev/null 2>&1; then
        output_fail "🛑 Docker Network 'nginx-proxy' does not exist!"
        output_fail "  Installation will be cancelled."
        output_fail "  Script ${ScriptFullName} exiting ... "
        output_fail "---------------------------------------------------------------------------"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    else
        output_okay "✅ Docker-Network 'nginx-proxy' found."
        output_okay "   $(docker network inspect nginx-proxy --format 'Subnet:   {{(index .IPAM.Config 0).Subnet}}{{"\n"}}   Gateway:  {{(index .IPAM.Config 0).Gateway}}')"
    fi
    output_null
COMMENT

}


# ----- Function → PrintSystemInfo -------------------------------------------------------
# This function simply prints some System Information
PrintSystemInfo() {
    output_note "💡 Current System Config:"
    output_note "---------------------------------------------------------------------------"
    output_note "Current User:  $(whoami)"
    output_note "Host Name:     ${MACHINE_NAME}"
    output_note "Host IP (v4):  $(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')"
    output_note "Domain (TLD):  *.${MACHINE_NAME}"
    output_note "Domain (SUB):  *.${MACHINE_NAME}.localhost"
    output_null
    output_note "Docker Information:"
    output_note "$(docker --version)"
    output_note "$(docker compose version)"
    output_note "---------------------------------------------------------------------------"
    output_null
}


# ----- Function → SetFolderPermission ---------------------------------------------------
# This function needs 3 Arguments. Sets the given folder permissions to a given folder
SetFolderPermission() {

    local mode="$1"
    local owner="$2"
    local path="$3"

    # Make sure that we have all given params
    if [ -z "${mode}" ] || [ -z "${owner}" ] || [ -z "${path}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   One or more missing arguments found!"
        output_warn "   Usage: ${FUNCNAME} <mode> <owner> <path>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi

    # Make sure that the given path exists
    if [ ! -d "${path}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   Path '${path}' does not exist!"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi

    # Check if we have a valid chmod value
    if ! [[ "${mode}" =~ ^[0-7]{3,4}$ ]]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   '${mode}' is an invalid value for 'mode'!"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi

    # Check if we have a valid chown value
    if ! [[ "$owner" =~ ^[0-9]+$ ]]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   '${owner}' is an invalid value for 'owner'!"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi

    output_info "ℹ️ Setting permissions for '${path}'. Please wait ..."
    sudo chmod -R $mode $path
    sudo chown -R $owner:$owner $path
    output_okay "✅ Done."

}


# ----- Function → VerifyFileCreated -----------------------------------------------------
# This function needs two arguments. Checks if the given file could be created
VerifyFileCreated() {

    local file="$1"
    local action="$2"

    if [ -z "${file}" ] || [ -z "${action}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   One or more missing arguments found!"
        output_warn "   Usage: ${FUNCNAME} <path> <action>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi
    
    # Verify if given file exists or not
    if [ ! -f "${file}" ]; then
        if [ "${action}" = "warn"]; then
            output_warn "⚠️ Failed to create ${file}!"
        elif [ "${action}" = "exit"]; then
            output_fail "🛑 Failed to create ${file}!"
            output_fail "   Cannot continue without this file!"
            output_fail "---------------------------------------------------------------------------"
            output_fail "${FUNCNAME} will be terminated prematurely!"
            output_null
            read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
            exit 1
        else
            output_warn "⚠️ Failed to create ${file}!"
        fi
    else
        output_okay "✅ Done."
        output_okay "   ${file} successfully created."
    fi
    output_null

}


# ----- Function → VerifyPathCreated -----------------------------------------------------
# This function needs two arguments. Checks if the given path could be created
VerifyPathCreated() {

    local path="$1"
    local action="$2"

    if [ -z "${path}" ] || [ -z "${action}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   One or more missing arguments found!"
        output_warn "   Usage: ${FUNCNAME} <path> <action>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi
    
    # Verify if given file exists or not
    if [ ! -d "${path}" ]; then
        if [ "${action}" = "warn"]; then
            output_warn "⚠️ Failed to create ${path}!"
        elif [ "${action}" = "exit"]; then
            output_fail "🛑 Failed to create ${path}!"
            output_fail "   Cannot continue without this directory!"
            output_fail "---------------------------------------------------------------------------"
            output_fail "${FUNCNAME} will be terminated prematurely!"
            output_null
            read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
            exit 1
        else
            output_warn "⚠️ Failed to create ${path}!"
        fi
    else
        output_okay "✅ Done."
        output_okay "   ${path} successfully created."
    fi
    output_null

}


# ----- Function → VerifyFile ------------------------------------------------------------
# This function needs two arguments. Checks if the given file exists
VerifyFile() {

    local file="$1"
    local action="$2"

    if [ -z "${file}" ] || [ -z "${action}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   One or more missing arguments found!"
        output_warn "   Usage: ${FUNCNAME} <file> <action>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi
    
    # Verify if given file exists or not
    if [ ! -f "${file}" ]; then
        if [ "${action}" = "warn"]; then
            output_warn "⚠️ File '${file}' does not exist!"
        elif [ "${action}" = "exit"]; then
            output_fail "🛑 File '${file}' does not exist!"
            output_fail "   Cannot continue without this file!"
            output_fail "---------------------------------------------------------------------------"
            output_fail "${FUNCNAME} will be terminated prematurely!"
            output_null
            read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
            exit 1
        else
            output_warn "⚠️ File '${file}' does not exist!"
        fi
    else
        output_okay "✅ File '${file}' found!"
    fi
    output_null

}


# ----- Function → VerifyPath ------------------------------------------------------------
# This function needs two arguments. Checks if the given file exists
VerifyPath() {

    local path="$1"
    local action="$2"

    if [ -z "${path}" ] || [ -z "${action}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   One or more missing arguments found!"
        output_warn "   Usage: ${FUNCNAME} <path> <action>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi
    
    # Verify if given file exists or not
    if [ ! -d "${path}" ]; then
        if [ "${action}" = "warn"]; then
            output_warn "⚠️ Path '${path}' does not exist!"
        elif [ "${action}" = "exit"]; then
            output_fail "🛑 Path '${path}' does not exist!"
            output_fail "   Cannot continue without this directory!"
            output_fail "---------------------------------------------------------------------------"
            output_fail "${FUNCNAME} will be terminated prematurely!"
            output_null
            read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
            exit 1
        else
            output_warn "⚠️ Path '${path}' does not exist!"
        fi
    else
        output_okay "✅ Done."
        output_okay "   Path '${path}' found!"
    fi
    output_null

}


# ----- Function → RestartDockerDaemon ---------------------------------------------------
# This function will performn a restart of the docker daemon
RestartDockerDaemon() {

    # Is Docker Daemon running and reachable?
    if ! docker info >/dev/null 2>&1; then
        output_warn "⚠️ Docker Daemon is not running or not reachable!"
        output_warn "   Trying to start Docker Daemon. Please wait ... "
        sudo systemctl start docker
    else
        output_okay "✅ Running Docker Daemon found."
        output_info "ℹ️ Restarting Docker Daemon to apply changes ..."
        sudo systemctl restart docker
    fi
    
    # Verify that Docker Daemon restart was successfull?
    if ! docker info >/dev/null 2>&1; then
        output_warn "⚠️ Failed restarting Docker Daemon!"
        output_warn "   Docker Daemon needs to be started manually!"
        output_null
    else
        output_okay "✅ Done."
        output_okay "   Docker Daemon successfully restarted."
        output_null
    fi

}


# ----- Function → CreateLocalMountPoint -------------------------------------------------
# Usage:  CreateLocalMountPoint "/full/path/to/folder" 775 1000
# This function needs three arguments.
# Tries to create a loca folder/path as a mount point for a docker container
CreateLocalMountPoint() {

    local MountPoint="$1"
    local UserAccess="$2"
    local MountOwner="$3"
    
    output_info "ℹ️ Trying to create new Mount Point. Please wait ..."
    
    # Check if all arguments are given
    if [ -z "${MountPoint}" ] || [ -z "${UserAccess}" ] || [ -z "${MountOwner}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   One or more missing arguments found!"
        output_warn "   Usage: ${FUNCNAME} <MountPoint> <UserAccess> <MountOwner>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi
    # Check if we have a valid chmod value
    if ! [[ "${UserAccess}" =~ ^[0-7]{3,4}$ ]]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   '${UserAccess}' is an invalid value for 'UserAccess'!"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi
    # Check if we have a valid chown value
    if ! [[ "$MountOwner" =~ ^[0-9]+$ ]]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   '${MountOwner}' is an invalid value for 'MountOwner'!"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi

    # We need to make sure that the MountPoint does not exist
    if [ -d "${MountPoint}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   '${MountPoint}' already exists!"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    else
        # At this point we can be sure that the path does not exist
        # → Let's create the new MountPoint
        sudo mkdir -p $MountPoint
        # Verify that the directory could be created
        if [ -d "${MountPoint}" ]; then
            output_okay "✅ Done."
            output_okay "   ${MountPoint} successfully created."
            output_info "ℹ️ Setting folder permissions."
            sudo chmod -R $UserAccess $MountPoint
            sudo chown -R $MountOwner:$MountOwner $MountPoint
            output_okay "✅ Done."
        else
            output_warn "⚠️ Failed to create MountPoint ${MountPoint}!"
            output_warn "---------------------------------------------------------------------------"
            output_null
            read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
            exit 1
        fi
    fi
    output_null
}


# ----- Function → CreateNewDockerVolume -------------------------------------------------
# Usage:  CreateNewDockerVolume "MyDockerStorage" "MyDockerApp"
# This function needs two arguments.
# Tries to create a new Docker Volume for persistent data
CreateNewDockerVolume() {

    local Volume="$1"
    local AppName="$2"

    if [ -z "${Volume}" ] || [ -z "${AppName}" ]; then

        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   One or more missing arguments found!"
        output_warn "   Usage: ${FUNCNAME} <Volume> <AppName>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi

    output_info "ℹ️ Configuring Docker Volume '${Volume}'. Please wait ..."
    # First, we need to verify if the Volume already exists and if it is in use
    if docker volume inspect $Volume >/dev/null 2>&1; then
        if docker ps -a --filter volume=$Volume --format '{{.Names}}' | grep -q .; then
            # Docker Volume is still in use by another container!!
            output_fail "🛑 Docker Volume ${Volume} already exists"
            output_fail "   and is in use by another Docker Container!"
            output_fail "---------------------------------------------------------------------------"
            output_fail "${FUNCNAME} will be terminated prematurely!"
            output_null
            read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
            exit 1
        else
            # Docker Volume exists, but is not in use anymore → can be deleted!
            output_warn "⚠️ Docker Volume ${Volume} already exists but is not in use anymore."
            output_warn "   Removing old Docker Volume ${Volume} to prevent conflicts ..."
            output_warn "   $(docker volume rm $Volume)"
            if docker volume inspect $Volume >/dev/null 2>&1; then
                output_fail "🛑 Docker Volume ${Volume} could not be removed!"
                output_fail "---------------------------------------------------------------------------"
                output_fail "${FUNCNAME} will be terminated prematurely!"
                output_null
                read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
                exit 1
            else
                output_okay "✅ Done."
                output_okay "   Old Docker Volume ${Volume} successfully removed."
            fi
        fi
    else
      output_okay "✅ No previous Docker Volume ${Volume} found."
    fi
    output_info "ℹ️ Creating new Docker Volume ${Volume} now ..."
    output_info "   $(docker volume create --label project=$AppName --label env=prod $Volume)"
    # Verify, that the new Docker Volume could be created
    if docker volume inspect $Volume >/dev/null 2>&1; then
        output_okay "✅ Done."
        output_okay "   Docker Volume ${Volume} successfully created."
    else
        output_fail "🛑 Failed creating Docker Volume ${Volume} !"
        output_fail "---------------------------------------------------------------------------"
        output_fail "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi
    output_null
}


CreateDockerNetwork() {

    local network="$1"
    local gateway="$2"
    local subnet="$3"

    # make sure that we have all mandatory params
    if [ [-z "${network}"] || [-z "${gateway}"] || [-z "${subnet}"] ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   One or more mandatory argument missing!"
        output_warn "   Usage: CreateDockerNetwork <network> <gateway> <subnet>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi
    # check it the network name is already in use
    if docker network inspect $network >/dev/null 2>&1; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "Docker-Network '${network}' already exists!"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi
    # check it the IP/Gateway is already in use
    if docker network ls -q | xargs docker network inspect | grep -q "'Gateway': '${gateway}'"; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "Gateway '${gateway}' is already in use!"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi

    # If we reached this point, we can be sure that we have all mandatory params plus the
    # network name and the gateway are available. So we can create the new Docker Network!
    docker network create --driver bridge --attachable --subnet $subnet --gateway $gateway $network
    # verify that the new Docker Network could be created
    if docker network inspect $network >/dev/null 2>&1; then
        output_okay "✅ NetworkSuccessfully created."
        output_okay "   Name:       ${network}"
        output_okay "   Subnet:     ${subnet}"
        output_okay "   Gateway:    ${gateway}"
        output_null
    else
        output_fail "🛑 Failed creating Network '${network}'"
        output_fail "---------------------------------------------------------------------------"
        output_fail "${FUNCNAME} will be terminated!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi

}


# ----- Function → CreateNewFile ---------------------------------------------------------
# This function needs the following arguments: </path/to/file.txt> <override>
# Tries to create a new Docker Volume for persistent data. Verifies that the file could be created.
CreateNewFile() {

    local file="$1"
    local override="${2:-N}"

    if [ -z "${file}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   Argument 'file' is not defined!"
        output_warn "   Usage: CreateNewFile <file>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi
    case "${override}" in
        y|Y|n|N) ;;
        *)
            output_warn "⚠️ Error in function:  ${FUNCNAME}"
            output_warn "   '${override}' is an invalid value for 'override'!"
            output_warn "---------------------------------------------------------------------------"
            output_warn "${FUNCNAME} will be terminated prematurely!"
            output_null
            read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
            exit 1
            ;;
    esac
    #if [ ! [ "$override" =~ ^[yYnN]$ ]]; then
    #    output_warn "⚠️ Error in function:  ${FUNCNAME}"
    #    output_warn "   '${override}' is an invalid value for 'override'!"
    #    output_warn "---------------------------------------------------------------------------"
    #    output_warn "${FUNCNAME} will be terminated prematurely!"
    #    output_null
    #    read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
    #    exit 1
    #fi

    output_info "ℹ️ Trying to create '${file}'. Please wait ..."
    
    # Check if the file already exists or not
    if [ -f "${file}" ]; then
        output_warn "⚠️ File '${file}' already exists!"
        # File already exists. shall we override?
        if [ ["${override}"="y"] || ["${override}"="Y"] ]; then
            output_info "ℹ️ Removing file '${file}'."
            sudo rm -f $file
            if [ ! -f "${file}" ]; then
                output_okay "✅ Done."
            else
                output_fail "🛑 File '${file}' could not be removed!"
                output_fail "---------------------------------------------------------------------------"
                output_fail "${FUNCNAME} will be terminated prematurely!"
                output_null
                read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
                exit 1
            fi
        #elif [ "${override}"="n" || "${override}"="N" ]; then
        else
            output_warn "⚠️ Override-Mode was set to '${override}'!"
            output_warn "   Change Override-Mode to 'y' or remove the file manually!"
            output_warn "---------------------------------------------------------------------------"
            output_warn "${FUNCNAME} will be terminated prematurely!"
            output_null
            read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
            exit 1        
        fi
    else
        output_okay "✅ '${file}' does not exist. Creating new file ..."
    fi

    # Create the given file (0-Byte)
    sudo sh -c ": > ${file}"
    sleep 0.2

    # verify that the file could be created
    if [ -f "${file}" ]; then
        output_okay "✅ Done."
        output_okay "   '${file}' successfully created."
    else
        output_fail "🛑 Failed creating file"
        output_fail "   ${file}"
        output_fail "---------------------------------------------------------------------------"
        output_fail "${FUNCNAME} will be terminated!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi
    output_null
}


# ----- Function → CreateNewPath ---------------------------------------------------------
# CreateNewPath "/path/to/create" 775 1000
# This function tries to create the given path and sets the given permissions afterwards.
# Function verifies if the path could be created.
CreateNewPath() {

    local path="$1"
    local access="$2"
    local owner="$3"
    
    output_info "ℹ️ Trying to create '${path}'. Please wait ..."
    
    # Check if all arguments are given
    if [ -z "${path}" ] || [ -z "${access}" ] || [ -z "${owner}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   One or more missing arguments found!"
        output_warn "   Usage: ${FUNCNAME} <path> <access> <owner>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi
    # Check if we have a valid chmod value
    if ! [[ "${access}" =~ ^[0-7]{3,4}$ ]]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   '${access}' is an invalid value for 'access'!"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi
    # Check if we have a valid chown value
    if ! [[ "${owner}" =~ ^[0-9]+$ ]]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   '${owner}' is an invalid value for 'owner'!"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi

    # We need to make sure that the MountPoint does not exist
    if [ -d "${path}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   '${path}' already exists!"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    else
        # At this point we can be sure that the path does not exist
        # → Let's create the new MountPoint
        sudo mkdir -p $path
        # Verify that the directory could be created
        if [ -d "${path}" ]; then
            output_okay "✅ Done."
            output_okay "   ${path} successfully created."
            output_info "ℹ️ Setting folder permissions."
            sudo chmod -R $access $path
            sudo chown -R $owner:$owner $path
            output_okay "✅ Done."
        else
            output_fail "🛑 Failed to create directory ${path}!"
            output_fail "---------------------------------------------------------------------------"
            output_fail "${FUNCNAME} will be terminated prematurely!"
            output_null
            read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
            exit 1
        fi
    fi
    output_null
}


# ----- Function → GetFileSize -----------------------------------------------------------
# This Function needs one argument. Tries to get the file size of the given file and
# returns its size in kb (Note: Only the filesize without unit will be returned!)
# Usage:  size=$(GetFileSize "/path/to/file.yml")
GetFileSize() {

    local file="$1"

    # Verify that the argument isn't empty
    if [ -z "${file}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   Argument 'file' is not defined!"
        output_warn "   Usage: ${FUNCNAME} <file>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi
    # verify that the file exists
    if [ ! -f "${file}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   File '${file}' does not exist!"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    else
        local filesize=$(stat -c%s "${file}")
        echo $filesize
    fi
}


# ----- Function → FileLookup ------------------------------------------------------------
# USAGE:  FileLookup "/path/to/my/file.txt"
FileLookup() {
    # Get the passed argument
    local file="$1"
    # Verify that the argument isn't empty
    if [ -z "${file}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   Argument 'file' is not defined!"
        output_warn "   Usage: ${FUNCNAME} <file>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi
    # Check if the given file exsists
    if [ -f "$file" ]; then
        echo "ok"
        return 0
    elif ! [ -f "$file" ]; then
        echo "xx"
        return 1
    else
        echo "??"
        return 1
    fi
}


# ----- Function → PathLookup ------------------------------------------------------------
# USAGE:  PathLookup "/path/to/folder"
PathLookup() {
    # Get the passed argument
    local path="$1"
    # Verify that the argument isn't empty
    if [ -z "${path}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   Argument 'path' is not defined!"
        output_warn "   Usage: ${FUNCNAME} <path>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi
    # Check if the given file exsists
    if [ -d "$path" ]; then
        echo "ok"
        return 0
    elif ! [ -d "$path" ]; then
        echo "xx"
        return 1
    else
        echo "??"
        return 1
    fi
}


# ----- Function → CreateNewRootCA -------------------------------------------------------
# USAGE:   CreateNewRootCA <PATH> <KEY> <PEM> <SUBJ>
# SAMPLE:  CreateNewRootCA "/path/to/folder" "rootCA" "rootCA" "/CN=Praetoriani"
# SAMPLE:  CreateNewRootCA "/path/to/folder" "root-key" "root-crt" "/CN=*.localhost"
CreateNewRootCA() {
    # Get the passed argument
    local path="$1"
    local key="$2"
    local pem="$3"
    local subj="$4"

    # Verify that the argument isn't empty
    if [ -z "${path}" ] || [ -z "${key}" ] || [ -z "${pem}" ] || [ -z "${subj}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   At least one mandatory argument is missing!"
        output_warn "   Usage: ${FUNCNAME} <PATH> <KEY> <PEM> <SUBJ>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi

    # Check if the given store exsists
    local lookup="$(PathLookup "${path}")"
    if [ "$lookup" = "xx" ]; then
        sudo mkdir -p $path
        lookup="$(PathLookup "${path}")"
        if ! [ "$lookup" = "ok" ]; then
            output_fail "🛑 Error in function:  ${FUNCNAME}"
            output_fail "   Following directory doesn't exist and cannot be created!"
            output_fail "   ${path}"
            output_fail "---------------------------------------------------------------------------"
            output_fail "${FUNCNAME} will be terminated prematurely!"
            output_fail
            read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
            exit 1
        fi
    elif [ "$lookup" = "??" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   Could not verify if following path exists or not:"
        output_warn "   ${path}"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi

    openssl genrsa -out "${path}/${key}.key" 4096
    openssl req -x509 -new -nodes -key "${path}/${key}.key" -sha256 -days 3650 -out "${path}/${pem}.pem" -subj "${subj}"

    local check_crt=$(FileLookup "${path}/${key}.key")
    local check_pem=$(FileLookup "${path}/${pem}.pem")

    if [ "$check_crt" = "ok" ] && [ "$check_pem" = "ok" ]; then
        echo "ok"
        return 0
    else
        echo "xx"
        return 1
    fi
}


# ----- Function → CreateAuthPass --------------------------------------------------------
# Usage:   CreateAuthPass <USER> <PASS>
# Sample:  CreateAuthPass "admin" "Simpl3P4ssw0rd"
#hash=$(CreateAuthPass "admin" "Simpl3P4ssw0rd")
#if [[ $? -ne 0 ]]; then
#    echo "Hash konnte nicht erzeugt werden"
#    exit 1
#fi
#
#echo "Generated Hash:"
#echo "$hash"
CreateAuthPass() {
    # Get the passed argument
    local user="$1"
    local pass="$2"
    local output
    local exitcode

    # Verify that the argument isn't empty
    if [ -z "${user}" ] || [ -z "${pass}" ]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   At least one mandatory argument is missing!"
        output_warn "   Usage: ${FUNCNAME} <USER> <PASS>"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi

    command -v htpasswd >/dev/null || {
        #echo "Fehler: htpasswd ist nicht installiert" >&2
        output_fail "🛑 Runtime Error in function:  ${FUNCNAME}"
        output_fail "   → htpasswd is not installed on your system!"
        output_null
        output_fail "${FUNCNAME} requires apache2-utils to use htpasswd!"
        output_fail "Please install  apache2-utils  on your system!"
        output_null
        #return 127
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    }

    # Run htpasswd and catch possible errors
    output=$(htpasswd -nb "$user" "$pass" 2>/dev/null)
    exitcode=$?

    if [[ $exitcode -ne 0 ]]; then
        output_warn "⚠️ Error in function:  ${FUNCNAME}"
        output_warn "   htpasswd faild generating a hash based on the following input:"
        output_warn "   Username:  ${user}"
        output_warn "   Password:  ${pass}"
        output_null
        output_warn "   Please try different Username and/or Password!"
        output_warn "---------------------------------------------------------------------------"
        output_warn "${FUNCNAME} will be terminated prematurely!"
        output_null
        #return $exitcode
        read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
        exit 1
    fi
    # Replace $ → $$  (for Makefiles oder HEREDOCs)
    #output=$(sed -e 's/\$/\$\$/g' <<< "$output")

    # Return generated Hash
    printf '%s' "$output"
    return 0
}


