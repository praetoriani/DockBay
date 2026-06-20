#!/usr/bin/env bash
cat << 'SCRIPT-INFO' > /dev/null
This Shell Script will install & configure the following App: PortCheckerIO
Place this script in /usr/local/bin make it executable and run it with sudo privileges
URL: https://github.com/dsgnr/portchecker.io/tree/devel
⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
TEST RESULTS:  SUCCESSFULLY TESTED ON WSL2/DEBIAN ON 06.06.2026
⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
Script Name:   install-portcheckerio.sh
Last Update:   14.06.2026
Written by:    Praetoriani
Website:       https://github.com/praetoriani
⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
SCRIPT-INFO

Load the WSL2 Library (important for this script)
source ../main/dockbay.lib.sh

START WITH A CLEAN CONSOLE
clear

SET THE INSTALLATION DIRECTORY (SILENTLY) BASED ON THE APP-TYPE
SetupLocationConfig "app"

Get the IP-Address of the WSL2/Debian Instance
HOST_IP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

THE FOLOWING SECTION IS A SET OF SCRIPT VARIABLES WHICH ARE USED TO CONFIGURE THE INSTALLATION OF THE DOCKER CONTAINER
CURRENT_USER=$(whoami)                              This is the current user (who executed this script)
#------------------------------------------------------------------------------------------------------------------------------------------------------
MAIN DOCKER CONFIGURATION
DOCKERDIR="/opt/docker"                             Absolute path to the root directory of the docker stacks
APP_FULL_NAME="Portchecker.io"                      Full name of the App that will be installed (only used for console output)
APP_NAME="portcheckerio"                            The folder name of the App (do not use spaces! only use lowercase and - or _ )
APP_SERVICE="PortCheckerIO"                         The Name of the Service (Container Name) for the Compose File
APP_COMPOSE="${APP_NAME}-compose.yml"               The name of the Docker Compose file (do not change this!)
DOCKERDIR="${DOCKBAY["ROOTPATH"]}"                  Absolute path to the root directory of the docker stacks
if [ "$SETUP_LOCATION" = "EMPTY"]; then
  APP_PATH="${DOCKBAY["APPSTACK"]}/${APP_NAME}"     Absolute path to the Installation Directory
else
  APP_PATH="${SETUP_LOCATION}/${APP_NAME}"          Absolute path to the Installation Directory
fi
#------------------------------------------------------------------------------------------------------------------------------------------------------
ADDITIONAL CONFIGURATION
APP_ENV_FILE=".env"                                 The name of the .env-file for the Docker Compose File
DB_PASSWORD="sql-pass.key"                          Only for Nginx! → Stores the password to access the database
USER_PASSWD="user-pass.key"                         Only for Nginx! → Stores the password for the admin user
APP_USERNAME="it-crew"                              The Username used for basic auth middleware
APP_PASSWORD="Ms+9uiXn%8ThJ*g"                      The Password used for basic auth middleware
#------------------------------------------------------------------------------------------------------------------------------------------------------
NETWORK CONFIGURATION
APP_PORT="8081"                                     This is the Port Number which will be exposed for public access
TCP_PORT="80"                                       This is the Port Number the Docker Container uses internally
SSL_PORT="443"                                      This is the Port Number the Docker Container uses for https
API_PORT="8000"                                     This is the Port Number the Docker Container uses for API
APP_IP="172.24.0.16"                                The (fixed) IP for the Docker Container (Gateway must already exist!)
API_IP="172.24.0.17"                                The (fixed) IP for the API Container
APP_DB_NAME="PortcheckerDB"                         This is the Name of the Database which is used by the Container
APP_DOMAIN="portchecker.localhost"                  This is the Domain/URL Traefik is going to use to expose this app
#------------------------------------------------------------------------------------------------------------------------------------------------------
VOLUME & LOCAL MOUNT POINTS
DATA_VOLUME="PortcheckerData"                       Name of the Docker Volume -> Only needed if app needs a Docker Volume!
MOUNTPOINT1="${APP_PATH}/data"                      Optional: Path to a local mount point for persistent data
MOUNTPOINT2="${APP_PATH}/letsencrypt"               Optional: Path to a local mount point for persistent data
MOUNTPOINT3="${APP_PATH}/mkcert"                    Optional: Path to a local mount point for persistent data


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
MANDATORY PRE-CHECKS

output_text "Script $0 started ..."
output_text "********************************************************************************"
output_null
Running System Prechecks from wsl2-lib.sh
DockerSystemPrecheck
Running Network Prechecks from wsl2-lib.sh
DockerNetworkPrecheck
At this point we can be sure that Docker is installed and reachable
Running Function from wsl2-lib.sh
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

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
MAIN SCRIPT EXECUTION

output_info "ℹ️ Creating ${APP_FULL_NAME} Directory structure. Please wait ..."

Using function from wsl2-lib.sh
CreateNewPath $APP_PATH 775 1000

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

Create Compose File using function from wsl2-lib.sh
CreateNewFile "${APP_PATH}/${APP_COMPOSE}" "Y"

output_info "ℹ️ Writing content to ${APP_COMPOSE}. Please wait ..."
Write new content to the compose file
cat << EOF > $APP_PATH/$APP_COMPOSE
----- NETWORK CONFIGURATION -------------------------
networks:
  #pcio-host-bridge:
   name: pcio-host-bridge
   driver: bridge
  apphost:
    external: true
    name: apphost

----- SERVICE CONFIGURATION -------------------------
services:
  PortCheckerIO:
    image: ghcr.io/dsgnr/portcheckerio-web:latest
    container_name: PortCheckerIO
    restart: unless-stopped

    Following Section is only important for Traefik Proxy
    labels:
      - "traefik.enable=true"

      Router for HTTP
      - "traefik.http.routers.${APP_NAME}.rule=Host(\`${APP_DOMAIN}\`)"
      - "traefik.http.routers.${APP_NAME}.entrypoints=web"

      Service → internal Port of the Container
      - "traefik.http.services.${APP_NAME}.loadbalancer.server.port=${TCP_PORT}"

      Router for HTTPS
      - "traefik.http.routers.${APP_NAME}-secure.rule=Host(\`${APP_DOMAIN}\`)"
      - "traefik.http.routers.${APP_NAME}-secure.entrypoints=websecure"
      - "traefik.http.routers.${APP_NAME}-secure.tls=true"

      Basic Auth Middleware
      - "traefik.http.middlewares.${APP_NAME}-auth.basicauth.users=${AUTH_HASH}"
      - "traefik.http.routers.${APP_NAME}.middlewares=${APP_NAME}-auth@docker"
      - "traefik.http.routers.${APP_NAME}.middlewares=${APP_NAME}-auth"
      - "traefik.http.routers.${APP_NAME}-secure.middlewares=${APP_NAME}-auth@docker"
      - "traefik.http.routers.${APP_NAME}-secure.middlewares=${APP_NAME}-auth"

    ports:
      - ${APP_PORT}:${TCP_PORT}
    networks:
      #pcio-host-bridge:
      apphost:
        ipv4_address: ${APP_IP}
    environment:
      Optional, Populates a default host address value to be populataed in the in the UI input. Defaults to external/WAN IP.
      - DEFAULT_HOST=localhost
      Optional, Populates a default port value to be populataed in the in the UI input
      - DEFAULT_PORT=${SSL_PORT}
      Optional, the URL of the API service. The scheme and port is required. Defaults to http://api:8000 if not set.
      - API_URL=http://PortCheckerIO-API:${API_PORT}

    healthcheck:
      test: ["CMD", "wget", "--spider", "-S", "http://127.0.0.1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 5s
    
    depends_on:
      - PortCheckerIO-API  Ensure api service is ready before web starts
  
  PortCheckerIO-API:
    image: ghcr.io/dsgnr/portcheckerio-api:latest
    container_name: PortCheckerIO-API
    restart: unless-stopped

    ports:
      - ${API_PORT}:${API_PORT}
    networks:
      #pcio-host-bridge:
      apphost:
        ipv4_address: ${API_IP}
    environment:
      - ALLOW_PRIVATE=false  Prevent usage of private IP addresses

    healthcheck:
      test: ["CMD", "wget", "--spider", "-S", "http://127.0.0.1:${API_PORT}/healthz"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 5s

EOF
Get the file size by using function from wsl2-lib.sh
Check if the size is 0 byte
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

Running SetFolderPermission from wsl2-lib.sh
SetFolderPermission 777 1000 $APP_PATH

Running RestartDockerDaemon from wsl2-lib.sh
RestartDockerDaemon

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
MAIN SCRIPT FINISHED - OPTIONALLY RUN 'DOCKER COMPOSE UP -D' RIGHT NOW

output_info "$0 finished."
output_info "Please consider restarting WSL2 to fully apply all changes."
output_null
output_info "Would you like to continue with running 'docker compose -f ${APP_COMPOSE} up -d'"
output_info "for ${APP_FULL_NAME} right now?"
output_null

set -euo pipefail

prompt="${GRAY_BOLD}Please press '${WHITE}x${GRAY_BOLD}' to quit or '${WHITE}i${GRAY_BOLD}' to run container:${NC}"

cleanup() {
  stty sane
  printf "\n"
}
trap cleanup EXIT

while true; do
  Print line and delete to end of line (\033[K)
  printf "\r\033[K%b" "$prompt"

  Read a character without Enter and without echo
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
      Invalid input: flash briefly or simply rewrite the line
      Optional: audible signal: printf '\a'
      We simply rewrite the line (no additional output)
      continue
      ;;
  esac
done

Following code will execute after 'i' section was executed
output_info "$0 finished."
output_null
output_info "${APP_FULL_NAME} can be accessed via following (internal) URL:"
output_null
output_text "http://localhost:${APP_PORT}"
output_text "or"
output_text "http://${HOST_IP}:${APP_PORT}"
output_null
output_info "Note: This Container will be handled by Traefik!"
output_info "→ http://${APP_DOMAIN}"
output_info "→ https://${APP_DOMAIN}"
output_null
output_text "Enjoy using your ${APP_FULL_NAME} installation :)"
output_null
output_text "📌 Please note:"
output_text "The access to  ${APP_DOMAIN}  is currently secured"
output_text "by Traefik Proxy using Basic Authentication Middleware."
output_text "Use the following credentials for login:"
output_text "Username:  ${APP_USERNAME}"
output_text "Password:  ${APP_PASSWORD}"
output_null
output_text "$0 is exiting now ..."
output_null
read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit ...\033[0m'
echo ""
exit 0

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
DOCUMENTATION AND USAGE INSTRUCTIONS


: <<'INFO'
TO BE DOCUMENTED ...
INFO
