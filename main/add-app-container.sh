#!/usr/bin/env bash
# This script first checks the current Situation of the installed Docker Containers
# and displays a result page including indicators which Containers are already present
# inside DockBay and which Containers are still missing
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
# Test Results:    ✓ Verified working
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
# Script Name:   add-app-container.sh
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
if [ "$(jq -r '.setup.containerscan' $SETUPCFGJSON)" = "true" ]; then
    output_null
    output_text "Checking current configuration. Please wait ..."
    output_null
    sleep 1.0
    for app in "${APPCONTAINER[@]}"; do
        ScanDockBayContainer "$app"
    done
    jq '.setup.containerscan = false' $SETUPCFGJSON > $SETUPTMPJSON && mv $SETUPTMPJSON $SETUPCFGJSON
    output_null
    output_text "Done"
    output_null
    sleep 2.0
fi
clear
PrintSetupScreen "3"
output_null
output_null
read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to go back to Main Screen ...\033[0m' && echo ""
clear
output_text "Going back to Main Screen."
output_null
sleep 1.0
exit 0