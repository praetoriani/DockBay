#!/usr/bin/env bash
cat << 'SCRIPT-INFO' > /dev/null
This Shell Script will install & configure the following App: BentoPDF
Place this script in /usr/local/bin make it executable and run it with sudo privileges
URL: https://www.mongodb.com/docs/manual/administration/install-community/
⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
TEST RESULTS:  NOT TESTED SINCE UPDATE
⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
Script Name:   install-bentopdf.sh
Last Update:   18.06.2026
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

# THE FOLOWING SECTION IS A SET OF SCRIPT VARIABLES WHICH ARE USED TO CONFIGURE THE INSTALLATION OF THE DOCKER CONTAINER
CURRENT_USER=$(whoami)                              # This is the current user (who executed this script)
#------------------------------------------------------------------------------------------------------------------------------------------------------
# MAIN DOCKER CONFIGURATION
APP_FULL_NAME="$(jq -r '.dockbay.app.bentopdf.fname' $DOCKBAYCONFIG)"              # Full name of the App that will be installed (only used for console output)
APP_NAME="$(jq -r '.dockbay.app.bentopdf.sname' $DOCKBAYCONFIG)"                   # The folder name of the App (do not use spaces! only use lowercase and - or _ )
APP_CONTAINER="$(jq -r '.dockbay.app.bentopdf.cname' $DOCKBAYCONFIG)"              # The Name of the Service (Container Name) for the Compose File
APP_IMAGE="$(jq -r '.dockbay.app.bentopdf.image' $DOCKBAYCONFIG)"                  # The Image that the container is going to use
APP_COMPOSE="$(jq -r '.dockbay.app.bentopdf.compose' $DOCKBAYCONFIG)"              # The name of the Docker Compose file (do not change this!)

if [ "$SETUP_LOCATION" = "EMPTY"]; then
  APP_PATH="$(jq -r '.dockbay.app.bentopdf.stack' $DOCKBAYCONFIG)/${APP_NAME}"     # Absolute path to the Installation Directory
else
  APP_PATH="${SETUP_LOCATION}/${APP_NAME}"                                         # Absolute path to the Installation Directory
fi
#------------------------------------------------------------------------------------------------------------------------------------------------------
# ADDITIONAL CONFIGURATION
#APP_ENV_FILE=".env"                                 # The name of the .env-file for the Docker Compose File
#------------------------------------------------------------------------------------------------------------------------------------------------------
# NETWORK CONFIGURATION
APP_PORT="$(jq -r '.dockbay.app.bentopdf.port.ext' $DOCKBAYCONFIG)"                # This is the Port Number which will be exposed for public access
TCP_PORT="$(jq -r '.dockbay.app.bentopdf.port.tcp' $DOCKBAYCONFIG)"                # This is the Port Number the Docker Container uses internally
APP_IP="$(jq -r '.dockbay.app.bentopdf.ip.apphost' $DOCKBAYCONFIG)"                # The (fixed) IP for the Docker Container (Gateway must already exist!)
APP_DOMAIN="$(jq -r '.dockbay.app.bentopdf.traefik.url' $DOCKBAYCONFIG)"           # This is the Domain/URL Traefik is going to use to expose this app
#------------------------------------------------------------------------------------------------------------------------------------------------------
# VOLUME & LOCAL MOUNT POINTS

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

# Create Compose File using function from wsl2-lib.sh
CreateNewFile "${APP_PATH}/${APP_COMPOSE}" "Y"

# Write new content to the compose file
output_info "ℹ️ Writing content to ${APP_COMPOSE}. Please wait ..."
cat << EOF > $APP_PATH/$APP_COMPOSE
services:
  ${APP_NAME}:
    image: ${APP_IMAGE}
    container_name: ${APP_CONTAINER}
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
      - "${APP_PORT}:${TCP_PORT}"
    networks:
      $(jq -r '.dockbay.app.bentopdf.network.apphost' $DOCKBAYCONFIG):
        ipv4_address: ${APP_IP}

    healthcheck:
      test: ['CMD', 'wget', '--spider', '-q', 'http://localhost:${TCP_PORT}']
      interval: 30s
      timeout: 10s
      retries: 3

networks:
  $(jq -r '.dockbay.app.bentopdf.network.apphost' $DOCKBAYCONFIG):
    external: true
EOF
# Get the file size by using function from wsl2-lib.sh
# Check if the size is 0 byte
if [ $(GetFileSize "${APP_PATH}/${APP_COMPOSE}") -eq 0 ]; then
  output_fail "🛑 Failed to write new content to ${APP_PATH}/${APP_COMPOSE}"
  output_fail "Script $0 exiting ... "
  output_fail "---------------------------------------------------------------------------"
  output_null
  read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
  exit 1
else
  output_okay "✅ Done."
  output_okay "   Content successfully written to ${APP_COMPOSE}"
  output_null
fi

# Running SetFolderPermission from wsl2-lib.sh
SetFolderPermission 777 1000 $APP_PATH

# Running RestartDockerDaemon from wsl2-lib.sh
RestartDockerDaemon

# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# MAIN SCRIPT FINISHED - OPTIONALLY RUN 'DOCKER COMPOSE UP -D' RIGHT NOW

output_text "$0 finished."
output_text "Please consider restarting WSL2 to fully apply all changes."
output_null
output_text "Would you like to continue with running 'docker compose -f ${APP_COMPOSE} up -d'"
output_text "for ${APP_FULL_NAME} right now?"
output_null

set -euo pipefail

prompt="${GRAY_BOLD}Please press '${WHITE}x${GRAY_BOLD}' to quit or '${WHITE}i${GRAY_BOLD}' to run container:${NC}"

cleanup() {
  stty sane
  printf "\n"
}
trap cleanup EXIT

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

# BEFORE WE CAN REALLY FINISH AND SHOW A FINAL INFORMATION,
# WE NEED TO VERIFY IF THE CONTAINER IS REALLY RUNNINT OR NOT!

if [ "$(CheckContainer "${APP_CONTAINER}")" = "xx" ]; then
  output_warn "⚠️ Error while running 'docker compose -f $APP_COMPOSE up -d'"
  output_warn "→ Docker Container ${APP_CONTAINER} could not be created!"
  output_null
  output_warn "Go to ${APP_PATH} and run the following command again:"
  output_text "docker compose -f $APP_COMPOSE up -d"
  output_warn "If it still doesn't work, remove the following directory"
  output_warn "and then return here and run the setup again."
  output_warn "${APP_PATH}"
  output_null
  output_text "$0 is exiting now ..."
  output_null
  read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit ...\033[0m'
  echo ""
  exit 0
else
  if [ "$(ContainerStatus "${APP_CONTAINER}")" = "xx" ]; then
    output_warn "⚠️ Error while running 'docker compose -f $APP_COMPOSE up -d'"
    output_warn "Docker Container ${APP_CONTAINER} was successfully created,"
    output_warn "but somehow it is currently not running!"
    output_null
    output_text "$0 is exiting now ..."
    output_null
    read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit ...\033[0m'
    echo ""
    exit 0
  fi
fi

##################################################
# 
#  DON'T FORGET !!!
# 
# WE NEED TO UPDATE THE JSON-FILE !!!
# 
##################################################

output_null
output_okay "✅ $0 successfully finished."
output_okay "→ Docker Container ${APP_CONTAINER} is up and running."
output_null
output_info "${APP_FULL_NAME} can be accessed via following (internal) URL:"
output_null
output_text "http://localhost:${APP_PORT}"
output_text "or"
output_text "http://${MACHINE_IPV4}:${APP_PORT}"
output_null
output_text "💡 This Container is managed by Traefik Proxy"
output_text "The App can be accessed via following URL:"
output_text "→ http://${APP_DOMAIN}/"
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
