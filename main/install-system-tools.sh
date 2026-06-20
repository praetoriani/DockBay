#!/usr/bin/env bash
# This Shell Script will install several system tools
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
# Test Results:    ✓ Verified working
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
# Script Name:   install-system-tools.sh
# Last Update:   14.06.2026
# Written by:    Praetoriani
# Website:       https://github.com/praetoriani
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆

# Load the WSL2 Library (important for this script)
CurrentScriptLocation="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"         # ← Gets the full path to the current location
source $CurrentScriptLocation/dockbay.lib.sh

set -euo pipefail

# START WITH A CLEAN CONSOLE
clear

# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# MANDATORY PRE-CHECKS

output_text "Script $0 started ..."
output_text "********************************************************************************"
output_null
output_text "Checking current configuration. Please wait ..."
output_null
sleep 0.5
# Get current config from global array and json
if [ "$(jq -r '.setup.systemtools' $SETUPCFGJSON)" = "false" ]; then
    output_text "Required Packages to install:  0"
    sleep 0.2
    output_text "Nothing to install."
    sleep 0.2
    output_text "Going back to Main Screen"
    output_null
    sleep 2.0
    exit 0
else
    output_text "Reuired Docker Packages to be installed on your system:"
    for pkg in "${REQUIRED_PKGS[@]}"; do
        output_text "${RED_BOLD}→  $pkg ${DARK_GRAY_BOLD}"
        sleep 0.1
    done
fi
output_null
output_text "All Packages will be installed one by one."
output_null
output_text "Please press '${WHITE_BOLD}c${DARK_GRAY_BOLD}' to continue or '${WHITE_BOLD}q${DARK_GRAY_BOLD}' to quit:"

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
        output_text "Starting Batch-Installation."
        output_null
        sleep 1.0
        output_info "ℹ️ Updating System. Please wait ..."
        sudo apt update && sudo apt upgrade -y
        for pkg in "${REQUIRED_PKGS[@]}"; do
            output_info "ℹ️ Currently installing:  $pkg"
            sudo apt install $pkg -y
        done
        output_okay "✅ Done."
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

# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# MAIN SCRIPT FINISHED

output_info "ℹ️ Script $0 finished."
output_info "We recommend to reboot your system to fully apply all changes."
output_null
read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to return to Main Screen ...\033[0m' && echo ""
output_text "$0 is exiting now ..."
output_null
clear
exit 0
