#!/usr/bin/env bash
cat << 'SCRIPT-INFO' > /dev/null
This Shell Script will install & configure the following App: Blinko
Place this script in /usr/local/bin make it executable and run it with sudo privileges
URL: https://docs.blinko.space/en/install#step-1-create-docker-compose-yml
⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
TEST RESULTS:  NOT TESTED SINCE UPDATE
⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
Script Name:   install-blinko.sh
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
APP_FULL_NAME="$(jq -r '.dockbay.app.blinko.fname' $DOCKBAYCONFIG)"              # Full name of the App that will be installed (only used for console output)
APP_NAME="$(jq -r '.dockbay.app.blinko.sname' $DOCKBAYCONFIG)"                   # The folder name of the App (do not use spaces! only use lowercase and - or _ )
APP_CONTAINER="$(jq -r '.dockbay.app.blinko.cname' $DOCKBAYCONFIG)"              # The Name of the Service (Container Name) for the Compose File
APP_IMAGE="$(jq -r '.dockbay.app.blinko.image' $DOCKBAYCONFIG)"                  # The Image that the container is going to use
APP_COMPOSE="$(jq -r '.dockbay.app.blinko.compose' $DOCKBAYCONFIG)"              # The name of the Docker Compose file (do not change this!)

if [ "$SETUP_LOCATION" = "EMPTY"]; then
  APP_PATH="$(jq -r '.dockbay.app.blinko.stack' $DOCKBAYCONFIG)/${APP_NAME}"     # Absolute path to the Installation Directory
else
  APP_PATH="${SETUP_LOCATION}/${APP_NAME}"                                       # Absolute path to the Installation Directory
fi
#------------------------------------------------------------------------------------------------------------------------------------------------------
# ADDITIONAL CONFIGURATION
#APP_ENV_FILE=".env"                                 # The name of the .env-file for the Docker Compose File
APP_SECRET="$(jq -r '.dockbay.app.blinko.secret' $DOCKBAYCONFIG)"                # A secret password used for session encryption
#------------------------------------------------------------------------------------------------------------------------------------------------------
# NETWORK CONFIGURATION
APP_PORT="$(jq -r '.dockbay.app.blinko.port.ext' $DOCKBAYCONFIG)"                # This is the Port Number which will be exposed for public access
TCP_PORT="$(jq -r '.dockbay.app.blinko.port.tcp' $DOCKBAYCONFIG)"                # This is the Port Number the Docker Container uses internally
APP_IP="$(jq -r '.dockbay.app.blinko.ip.apphost' $DOCKBAYCONFIG)"                # The (fixed) IP for the Docker Container (Gateway must already exist!)
SQL_IP="$(jq -r '.dockbay.app.blinko.ip.sqlhost' $DOCKBAYCONFIG)"                # The (fixed) IP for the db-cluster Network
APP_DB_NAME="$(jq -r '.dockbay.app.blinko.dbname' $DOCKBAYCONFIG)"               # This is the Name of the Database which is used by the Container
APP_DOMAIN="$(jq -r '.dockbay.app.blinko.traefik.url' $DOCKBAYCONFIG)"           # This is the Domain/URL Traefik is going to use to expose this app
#------------------------------------------------------------------------------------------------------------------------------------------------------
# VOLUME & LOCAL MOUNT POINTS
MOUNTPOINT1="${APP_PATH}$(jq -r '.dockbay.app.blinko.mountpoint.appdata' $DOCKBAYCONFIG)"

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
output_warn "⚠️ Important Information:"
output_warn "${APP_FULL_NAME} is connected to the PostgreSQL Database"
output_warn "inside the DB Cluster. ${APP_FULL_NAME} needs the following"
output_warn "Database inside your PostgreSQL Database Host: '${APP_DB_NAME}'"
output_warn ""
output_warn "Please make sure that this Database exists, before running"
output_warn "the container for the first time after installation!"
output_null
output_text "Please verify that the above informations are correct."
read -n 1 -s -r -p $'\033[1;38;5;244mPress any key to continue or CTRL+C to cancel ...\033[0m' && echo ""
output_null

# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# MAIN SCRIPT EXECUTION

output_info "ℹ️ Creating ${APP_FULL_NAME} Directory structure. Please wait ..."

# Using function from wsl2-lib.sh
CreateNewPath $APP_PATH 775 1000

# Creating new mountpoints using function from wsl2-lib.sh
CreateLocalMountPoint $MOUNTPOINT1 775 1000

# Create Compose File using function from wsl2-lib.sh
CreateNewFile "${APP_PATH}/${APP_COMPOSE}" "Y"

# Write new content to the compose file
output_info "ℹ️ Writing content to ${APP_COMPOSE}. Please wait ..."
cat << EOF > $APP_PATH/$APP_COMPOSE
services:
  ${APP_CONTAINER}:
    image: blinkospace/blinko:latest
    container_name: ${APP_CONTAINER}
    restart: always

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
      $(jq -r '.dockbay.app.blinko.network.apphost' $DOCKBAYCONFIG):
        ipv4_address: ${APP_IP}
      $(jq -r '.dockbay.app.blinko.network.sqlhost' $DOCKBAYCONFIG):
        ipv4_address: ${SQL_IP}
    
    environment:
      NODE_ENV: production
      # NEXTAUTH_URL: http://localhost:1111
      # IMPORTANT: If you want to use sso, you must set NEXTAUTH_URL to your own domain
      # NEXT_PUBLIC_BASE_URL: http://localhost:1111
      # IMPORTANT: Replace this with your own secure secret key!
      NEXTAUTH_SECRET: ${APP_SECRET}
      DATABASE_URL: postgresql://postgres_admin:P6k%2E5D%219FvCq%23hW%2BTk@postgresql:5432/${APP_DB_NAME}
    
    # Make sure you have enough permissions.
    volumes:
      - ${MOUNTPOINT1}:/app/.blinko 
    
    logging:
      options:
        max-size: "10m"
        max-file: "3"

    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://${APP_CONTAINER}:${TCP_PORT}/"]
      interval: 30s 
      timeout: 10s   
      retries: 5     
      start_period: 30s 

networks:
  $(jq -r '.dockbay.app.blinko.network.apphost' $DOCKBAYCONFIG):
    external: true
  $(jq -r '.dockbay.app.blinko.network.sqlhost' $DOCKBAYCONFIG):
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
output_warn "Impotant Information:"
output_warn "Start the App right after Installation and create"
output_warn "an 'Admin' Account! The first user who creates an"
output_warn "Account will automatically be the Admin (Owner)!"
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
