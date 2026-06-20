#!/usr/bin/env bash
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
# Test Results:    ✓ Verified working
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
# Script Name:   dockbay-setup.sh
# Last Update:   14.06.2026
# Written by:    Praetoriani
# Website:       https://github.com/praetoriani
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆

# Load the WSL2 Library (important for this script)
source ./main/dockbay.lib.sh
source ./main/dockbay-prechecks.sh

# START WITH A CLEAN CONSOLE
clear

# FIRST TIME RUN !!!
if [ ! -d "${DOCKBAY["ROOTPATH"]}" ]; then
  # CREATE THE ROOT FOLDER FOR THE DPCKBA PROJECT
  # Using function from wsl2-lib.sh
  CreateNewPath "${DOCKBAY["ROOTPATH"]}" 775 1000
  CreateNewPath "${DOCKBAY["SYSSTACK"]}" 775 1000
  CreateNewPath "${DOCKBAY["APPSTACK"]}" 775 1000
  CreateNewPath "${DOCKBAY["SQLSTACK"]}" 775 1000
  WriteLogfile $SETUPLOG "→ dockbay-setup.sh started ..." "Y"
  WriteLogfile $SETUPLOG "→ DockBay Directories created at:  ${DOCKBAY["ROOTPATH"]}"
  clear
else
  # NOT THE FIRST TIME
  # REMOVE ANY PREVIOUSLY CREATED LOGFILES
  if [ "$(FileLookup $SETUPLOG)" = "ok" ]; then
      rm -f $SETUPLOG
  fi
  WriteLogfile $SETUPLOG "→ dockbay-setup.sh started ..." "Y"
fi

# Get the current location of the DockBay Setup Scripts
DockBayScriptLocation="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"         # ← Gets the full path to the current location
WriteLogfile $SETUPLOG "→ \$DockBayScriptLocation:  ${DockBayScriptLocation}"

# COPY THE JSON FILES TO THE INSTALLATION DIRECTORY (ONLY IF THEY DO NOT EXIST!)
checkfile=$(FileLookup $SETUPCFGJSON)
if [ "$checkfile" = "xx" ]; then
  WriteLogfile $SETUPLOG "→ Copying new setup.config.json"
  sudo cp -f $DockBayScriptLocation/main/setup.config.json $SETUPCFGJSON
else
  WriteLogfile $SETUPLOG "→ Using existing setup.config.json"
fi
if [ "$(FileLookup $DOCKBAYCONFIG)" = "xx" ]; then
  WriteLogfile $SETUPLOG "→ Copying new dockbay.config.json"
  sudo cp -f $DockBayScriptLocation/main/dockbay.config.json $DOCKBAYCONFIG
else
  WriteLogfile $SETUPLOG "→ Using existing dockbay.config.json"
fi

# THE FOLOWING SECTION IS A SET OF SCRIPT VARIABLES WHICH ARE USED TO CONFIGURE THE INSTALLATION OF THE DOCKER CONTAINER
CURRENT_USER=$(whoami)                              # This is the current user (who executed this script)

# This funcion executes the scipts based on the menu selection
RunMenuSelection() {
  case "$1" in
    1)
      sudo bash "./main/install-system-tools.sh"
      ;;
    2)
      sudo bash "./main/install-docker-ce.sh"
      ;;
    3)
      sudo bash "./main/install-dbcluster.sh"
      ;;
    4)
      sudo bash "./main/install-traefik.sh"
      ;;
    5)
      sudo bash "./main/add-app-container.sh"
      ;;
    x|X)
      WriteLogfile $SETUPLOG "→ User pressed:  $key"
      output_text "Okay ... "
      sleep 0.5
      output_text "Just run this script again, if you change your mind 😊"
      sleep 0.5
      output_text "Thank You for choosing  🐳 DockBay"
      sleep 0.5
      output_text "Have a nice day 🫶🏻"
      sleep 0.5
      printf "\r\033[K%b\n" "${ORANGE_DARK_BOLD} $0 is exiting now ...${NC}"
      sleep 0.5
      exit 0
      ;;
    *)
      # Invalid input: flash briefly or simply rewrite the line
      # Optional: audible signal: printf '\a'
      # We simply rewrite the line (no additional output)
      continue
      ;;
  esac
}



# PRECHECKS
output_text "Script $0 started ..."
output_text "********************************************************************************"
output_null
# THE PRECHECKS WILL ONLY BE EXECUTED ONCE, DEPENDING ON THE INFORMATION FROM THE JSON
if [ "$(jq -r '.setup.dockbaychecks' $SETUPCFGJSON)" = "true" ]; then
  output_text "Performing mandatory prechecks. Please wait ... "
  output_null
  PerformDockBayPrechecks
  read -n 1 -s -r -p $'\033[1;38;5;244mPress any key to continue or CTRL+C to cancel ...\033[0m' && echo ""
  clear
  PrintSetupScreen "1"
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
        WriteLogfile $SETUPLOG "→ User pressed:  $key"
        output_text "Okay ... "
        sleep 0.5
        output_text "Just run this script again, if you change your mind 😊"
        sleep 0.5
        output_text "Thank You for choosing  🐳 DockBay"
        sleep 0.5
        output_text "Have a nice day 🫶🏻"
        sleep 0.5
        printf "\r\033[K%b\n" "${ORANGE_DARK_BOLD} $0 is exiting now ...${NC}"
        sleep 0.5
        exit 0
        ;;
      c|C)
        WriteLogfile $SETUPLOG "→ User pressed:  $key"
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
fi
clear

while true; do
  PrintSetupScreen "2"
  output_text "Please enter a number between '${WHITE_BOLD}1${DARK_GRAY_BOLD}' and '${WHITE_BOLD}5${DARK_GRAY_BOLD}' to continue or press '${WHITE_BOLD}x${DARK_GRAY_BOLD}' to quit:"
  read -rp "${DARK_GRAY_BOLD}→ ${NC}" choice
  RunMenuSelection "$choice"
  output_null
  #output_text "$(read -rp "Press any key to go back to the Main Screen.")"
  clear
done

#trap 'rm -f "$SETUPLOG"' EXIT