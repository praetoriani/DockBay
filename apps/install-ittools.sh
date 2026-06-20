#!/usr/bin/env bash
cat << 'SCRIPT-INFO' > /dev/null
This Shell Script will install & configure the following App: IT-Tools
Place this script in /usr/local/bin make it executable and run it with sudo privileges
URL: https://github.com/CorentinTh/it-tools
⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
TEST RESULTS:  SUCCESSFULLY TESTED ON WSL2/DEBIAN ON 06.06.2026
⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
Script Name:   install-ittools.sh
Last Update:   14.06.2026
Written by:    Praetoriani
Website:       https://github.com/praetoriani
⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
SCRIPT-INFO

# Load the WSL2 Library (important for this script)
source ../main/dockbay.lib.sh

# START WITH A CLEAN CONSOLE
clear

# SET THE INSTALLATION DIRECTORY (SILENTLY) BASED ON THE APP-TYPE
SetupLocationConfig "app"

# Get the IP-Address of the WSL2/Debian Instance
HOST_IP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# THESE VARIABLES DEFINE WHERE THE APP WILL BE INSTALLED.
# DEFAULT INSTALLATION PATH IS: home/CURRENT_USER/APP_NAME
# IF YOU WAN TO INSTAL TH APP TO A DIFFERENT LOCATION,
# PLEASE CHANGE THE VARIABLES BELOW ACCORDINGLY!
CURRENT_USER=$(whoami)                                # Stores the username of the current user
DOCKERDIR="/opt/docker"                               # Base directory path for all Docker-Related components
APP_FULL_NAME="IT-Tools"                              # The full name of the App
APP_NAME="ittools"                                    # The foldername for the App (don't use spaces here)
APP_SERVICE="IT-Tools"                                # The Name of the Service (Container Name)
APP_PORT="8082"                                       # The Port on which the App should be accessible (Host Port)
TCP_PORT="80"                                         # The Port inside the Docker Container (TCP Port)
APP_IP="172.24.0.9"                                   # The (fixed) IP for the Docker Container (Gateway must already exist!)
#NPM_IP="172.50.0.16"                                 # The (fixed) IP for the nginx-proxy Network
APP_DOMAIN="it-tools.localhost"                       # This is the Domain/URL Traefik is going to use to expose this app
APP_COMPOSE="${APP_NAME}-compose.yml"                 # The name of the Docker Compose file (do not change this!)
DOCKERDIR="${DOCKBAY["ROOTPATH"]}"                    # Absolute path to the root directory of the docker stacks
if [ "$SETUP_LOCATION" = "EMPTY"]; then
  APP_PATH="${DOCKBAY["APPSTACK"]}/${APP_NAME}"       # Absolute path to the Installation Directory
else
  APP_PATH="${SETUP_LOCATION}/${APP_NAME}"            # Absolute path to the Installation Directory
fi
DATA_VOLUME="ITstorage"                               # Name of the Docker Volume -> Only needed if app needs a Docker Volume!
# ADDITIONAL VARIABLES
APP_ENV_FILE=".env"                                   # The name of the .env-file for the Docker Compose File
APP_USERNAME="it-crew"                                # The Username used for basic auth middleware
APP_PASSWORD="8TiXn%hJ*gMs+9u"                        # The Password used for basic auth middleware

# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# MANDATORY PRE-CHECKS

output_text "Script $0 started ..."
output_text "********************************************************************************"
output_null
# Running System Prechecks from wsl2-lib.sh
DockerSystemPrecheck
# Running Network Prechecks from wsl2-lib.sh
DockerNetworkPrecheck
# At this point we can be sure that Docker is installed and reachable
# Running Function from wsl2-lib.sh
PrintSystemInfo
output_text "********************************************************************************"
output_null

output_text "This script will install & configure the following application:"
output_null
output_text "Application Name:    ${APP_FULL_NAME}"
output_text "Install Directory:   ${APP_PATH}"
output_null
output_text "Please verify that the above informations are correct."
read -n 1 -s -r -p $'\033[1;38;5;244mPress any key to continue or CTRL+C to cancel ...\033[0m' && echo ""
output_null

# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# MAIN SCRIPT EXECUTION

output_info "ℹ️ Creating ${APP_FULL_NAME} Directory structure. Please wait ..."

# Using function from wsl2-lib.sh
CreateNewPath $APP_PATH 775 1000

cat << 'COMMENT' > /dev/null
output_info "ℹ️ Creating Hash for Basuc Auth Middleware. Please wait ..."
AUTH_HASH=$(htpasswd -nb $APP_USERNAME "${APP_PASSWORD}" | sed -e 's/\$/\$\$/g')
if [ -z "$AUTH_HASH" ]; then
  output_fail "🛑 Failed generating hash for default admin account!"
  output_fail "This hash is important for basic middleware authentication!"
  output_fail "Installation cannot continue without this hash!"
  output_fail "Script $0 exiting ... "
  output_fail "---------------------------------------------------------------------------"
  output_fail "Make sure that you have 'apache2-utils' installed on your system!"
  output_null
  read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
  exit 1
else
  output_okay "✅ Done."
  output_okay "   Hash successfully created."
  output_okay "   →  ${AUTH_HASH}"
  output_null
fi

# ----------------------------------------------------------------------------------------------------
# Due to this container will be secured (using Basic Auth Middleware),
# we're going to ask for Username/Password to use for later login.
output_null
output_text "○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○"
output_null
output_text "📌 Please note:"
output_text "The access to  ${APP_DOMAIN}  will be secured"
output_text "by Traefik Proxy using Basic Authentication Middleware."
output_text "This means: If you want to access the above mentioned URL"
output_text "you need to enter Username/Password first!"
output_null
output_text "In the next step you can create your own Username/Password,"
output_text "or you just skip this step and we're going to use our own"
output_text "default authentication (will be displayed at the end)".
output_null
output_warn "⚠️ Warning!"
output_warn "1. Once started, you cannot quit the Username/Password config!"
output_warn "2. Your input can't be changed anymore after finishing the process!"
output_null
output_text "○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○"
output_null

set -euo pipefail

prompt="${GRAY_BOLD}Please press '${WHITE}s${GRAY_BOLD}' to skip or '${WHITE}c${GRAY_BOLD}' to continue:${NC}"

cleanup1() {
  stty sane
  printf "\n"
}
trap cleanup1 EXIT

while true; do
  # Print line and delete to end of line (\033[K)
  printf "\r\033[K%b" "$prompt"

  # Read a character without Enter and without echo
  IFS= read -r -n1 -s key

  case "$key" in
    s|S)
      output_text "→ User entered:  $key"
      sleep 0.2
      output_text "  ... skipping Username/Password config ..."
      sleep 0.2
      output_text "  ... using default credentials instead ..."
      sleep 0.2
      output_null
      sleep 0.2
      break
      ;;
    c|C)
      output_text "→ User entered:  $key"
      sleep 0.2
      output_text "→ Starting Username/Password Configuration"
      sleep 0.2
      output_null
      output_text "📌 Please note:"
      output_text "Username must be min. 4 and Password min. 8 chars!"
      output_null
      sleep 0.2
      USERNAME_INPUT=$(ReadUsername 4)
      output_okay "✅ Done. Username successfully set."
      sleep 0.2
      PASSWORD_INPUT=$(ReadPassword 8)
      output_okay "✅ Done. Password successfully set."
      sleep 0.2
      output_text "We're going to use the following credentials:"
      output_text "Username:  $USERNAME_INPUT"
      output_text "Password:  $PASSWORD_INPUT"
      output_null
      sleep 0.2
      output_text "Trying to create secure hash using given credentials ..."
      SECURE_AUTH_HASH=$(CreateAuthPass "$USERNAME_INPUT" "$PASSWORD_INPUT")
      if [[ $? -ne 0 ]]; then
        output_fail "🛑 Failed creating secure hash using given credentials!"
        output_fail "   → Going to use default credentials as fallbackk now!"
        output_null
        unset SECURE_AUTH_HASH
      fi
      output_okay "✅ Done. Secure hash successfully created."
      output_null
      sleep 1.0
      output_text "Username/Password Configuration done."
      output_text "Returning to main setup process. Please wait ..."
      output_null
      sleep 2.0
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
# ----------------------------------------------------------------------------------------------------
COMMENT

# Create Compose File using function from wsl2-lib.sh
CreateNewFile "${APP_PATH}/${APP_COMPOSE}" "Y"

# Write new content to the compose file
output_info "ℹ️ Writing content to ${APP_COMPOSE}. Please wait ..."
cat << EOF > $APP_PATH/$APP_COMPOSE
services:
  ${APP_SERVICE}:
    image: ghcr.io/corentinth/it-tools:latest
    container_name: ${APP_SERVICE}
    restart: unless-stopped

    # Following Section is only important for Traefik Proxy
    labels:
      - "traefik.enable=true"

      # Router for HTTP
      - "traefik.http.routers.${APP_NAME}.rule=Host(\`${APP_DOMAIN}\`)"
      - "traefik.http.routers.${APP_NAME}.entrypoints=web"

      # Service → internal Port of the Container
      - "traefik.http.services.${APP_NAME}.loadbalancer.server.port=${TCP_PORT}"

      # Router for HTTPS
      - "traefik.http.routers.${APP_NAME}-secure.rule=Host(\`${APP_DOMAIN}\`)"
      - "traefik.http.routers.${APP_NAME}-secure.entrypoints=websecure"
      - "traefik.http.routers.${APP_NAME}-secure.tls=true"
      
    ports:
      - ${APP_PORT}:${TCP_PORT}

    networks:
      apphost:
        ipv4_address: ${APP_IP}

networks:
  apphost:
    external: true
EOF
# Verify that the file could be created
if [ ! -f "${APP_PATH}/${APP_COMPOSE}" ]; then
    output_fail "Failed to create ${APP_COMPOSE} for ${APP_FULL_NAME}!"
    output_fail "Cannot continue without this file!"
    output_fail "Script $0 exiting ... "
    output_fail "---------------------------------------------------------------------------"
    output_null
    read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
    exit 1
else
    output_okay "Done."
    output_okay "${APP_COMPOSE} successfully created."
fi
output_null

# Restart Docker Daemon to apply changes
output_info "Restarting Docker Daemon to apply changes ..."
sudo systemctl restart docker
# Verify that Docker Daemon restart was successfull?
if ! docker info >/dev/null 2>&1; then
    output_warn "Failed restarting Docker Daemon!"
    output_warn "Docker Daemon needs to be restarted manually to apply changes."
    output_warn "---------------------------------------------------------------------------"
    output_null
else
  output_okay "Done."
  output_null
fi

# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# MAIN SCRIPT FINISHED - OPTIONALLY RUN 'DOCKER COMPOSE UP -D' RIGHT NOW

output_info "$0 finished."
output_info "Please consider restarting WSL2 to fully apply all changes."
output_null
output_info "Would you like to continue with running 'docker compose -f ${APP_COMPOSE} up -d'"
output_info "for ${APP_FULL_NAME} right now?"
output_null

set -euo pipefail

prompt="${GRAY_BOLD}Please press '${WHITE}x${GRAY_BOLD}' to quit or '${WHITE}i${GRAY_BOLD}' to run container:${NC}"

cleanup2() {
  stty sane
  printf "\n"
}
trap cleanup2 EXIT

while true; do
  # Print line and delete to end of line (\033[K)
  printf "\r\033[K%b" "$prompt"

  # Read a character without Enter and without echo
  IFS= read -r -n1 -s key

  case "$key" in
    x|X)
      output_text "Please Note:"
      output_text "You must run 'docker compose -f ${APP_COMPOSE} up -d' inside following directory:"
      output_text "${APP_PATH}"
      output_text "This will execute the ${APP_NAME} instance."
      output_null
      printf "\r\033[K%b\n" "${CYAN_BOLD} $0 is exiting now ...${NC}"
      exit 0
      ;;
    i|I)
      printf "\r\033[K%b\n" "${GREEN_BOLD}Continuing ...${NC}"
      output_null
      cd $APP_PATH
      docker compose -f $APP_COMPOSE up -d
      output_null
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

# Following code will execute after 'i' section was executed
output_info "$0 finished."
output_null
output_info "${APP_FULL_NAME} can be accessed via following URL:"
output_null
output_text "http://localhost:${APP_PORT}"
output_text "or"
output_text "http://${HOST_IP}:${APP_PORT}"
output_null
output_info "Note: This Container will be handled by Traefik!"
output_info "→ http://${APP_DOMAIN}"
output_info "→ https://${APP_DOMAIN}"
#output_null
#output_text "📌 Please note:"
#output_text "The access to  ${APP_DOMAIN}  is currently secured"
#output_text "by Traefik Proxy using Basic Authentication Middleware."
#output_text "Use the following credentials for login:"
#output_text "Username:  ${APP_USERNAME}"
#output_text "Password:  ${APP_PASSWORD}"
output_null
output_text "Enjoy using your ${APP_FULL_NAME} installation :)"
output_null
output_text "$0 is exiting now ..."
output_null
read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit ...\033[0m'
echo ""
exit 0

# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# DOCUMENTATION AND USAGE INSTRUCTIONS


: <<'INFO'
# TO BE DOCUMENTED ...
INFO
