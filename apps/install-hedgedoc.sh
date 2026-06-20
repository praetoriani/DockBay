#!/usr/bin/env bash
cat << 'SCRIPT-INFO' > /dev/null
This Shell Script will install & configure the following App: HedgeDoc
Visit https://docs.hedgedoc.org/setup/getting-started/ for more informations
Place this script in /usr/local/bin make it executable and run it with sudo privileges
⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
TEST RESULTS:  ✓ SUCCESSFULLY TESTED ON WSL2/DEBIAN ON 07.06.2026
⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
Script Name:   install-hedgedoc.sh
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

# THE FOLOWING SECTION IS A SET OF SCRIPT VARIABLES WHICH ARE USED TO CONFIGURE THE INSTALLATION OF THE DOCKER CONTAINER
CURRENT_USER=$(whoami)                              # This is the current user (who executed this script)
#------------------------------------------------------------------------------------------------------------------------------------------------------
# MAIN DOCKER CONFIGURATION
DOCKERDIR="/opt/docker"                             # Absolute path to the root directory of the docker stacks
APP_FULL_NAME="HedgeDoc"                            # Full name of the App that will be installed (only used for console output)
APP_NAME="hedgedoc"                                 # The folder name of the App (do not use spaces! only use lowercase and - or _ )
APP_SERVICE="HedgeDocApp"                           # The Name of the Service (Container Name) for the Compose File
APP_COMPOSE="${APP_NAME}-compose.yml"               # The name of the Docker Compose file (do not change this!)
DOCKERDIR="${DOCKBAY["ROOTPATH"]}"                  # Absolute path to the root directory of the docker stacks
if [ "$SETUP_LOCATION" = "EMPTY"]; then
  APP_PATH="${DOCKBAY["APPSTACK"]}/${APP_NAME}"     # Absolute path to the Installation Directory
else
  APP_PATH="${SETUP_LOCATION}/${APP_NAME}"          # Absolute path to the Installation Directory
fi
#------------------------------------------------------------------------------------------------------------------------------------------------------
# ADDITIONAL CONFIGURATION
APP_ENV_FILE=".env"                                 # The name of the .env-file for the Docker Compose File
#------------------------------------------------------------------------------------------------------------------------------------------------------
# NETWORK CONFIGURATION
APP_PORT="3010"                                       # This is the Port Number which will be exposed for public access
TCP_PORT="3010"                                       # This is the Port Number the Docker Container uses internally
APP_IP="172.24.0.11"                                  # The (fixed) IP for the Docker Container (Gateway must already exist!)
SQL_IP="172.30.0.8"                                   # The (fixed) IP for the db-cluster Network
APP_DB_NAME="HedgeDocDB"                              # This is the Name of the Database which is used by the Container
APP_DOMAIN="hedgedoc.localhost"                       # This is the Domain/URL Traefik is going to use to expose this app
#------------------------------------------------------------------------------------------------------------------------------------------------------
# VOLUME & LOCAL MOUNT POINTS
DATA_VOLUME="HedgeDocData"                            # Name of the Docker Volume -> Only needed if app needs a Docker Volume!
MOUNT_POINT="${APP_PATH}/uploads"                     # Path to a local mount point (for persistent data) -> Normally a subfolder of ${APP_PATH}


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
CreateLocalMountPoint $MOUNT_POINT 775 1000

# Create SSLCERT File using function from wsl2-lib.sh
CreateNewFile "${APP_PATH}/${APP_ENV_FILE}" "Y"

# Write new content to the Password file
output_info "ℹ️ Writing content to ${APP_PATH}/${APP_ENV_FILE}. Please wait ..."
cat << EOF > $APP_PATH/$APP_ENV_FILE
# ── Container Config ─────────────────────
APP_SERVICE=${APP_SERVICE}
APP_NAME=${APP_NAME}
# ── Container Netzwerk Config ────────────
CMD_DOMAIN=localhost
APP_PORT=${APP_PORT}
TCP_PORT=${TCP_PORT}
APP_IP=${APP_IP}
SQL_IP=${SQL_IP}
APP_DOMAIN=${APP_DOMAIN}
# ── Persistent Storage Config ────────────
MOUNT_POINT=${MOUNT_POINT}
# ── PostgreSQL Verbindung ────────────────
APP_DB_NAME=${APP_DB_NAME}
# Container-Name oder IP deines PostgreSQL-Containers
POSTGRES_HOST=PostgreSQL-Host
POSTGRES_PORT=5432
POSTGRES_USER=postgres_admin
POSTGRES_PASSWORD=P6k.5D!9FvCq#hW+Tk
POSTGRES_LABEL=PostgreSQL Host
# Vollstaendige PostgreSQL-URL für die Anmeldung
CMD_DB_URL=postgresql://postgres_admin:P6k%2E5D%219FvCq%23hW%2BTk@postgresql:5432/${APP_DB_NAME}
EOF
# Get the file size by using function from wsl2-lib.sh
# Check if the size is 0 byte
if [ $(GetFileSize "${APP_PATH}/${APP_ENV_FILE}") -eq 0 ]; then
  output_fail "🛑 Failed to write new content to ${APP_PATH}/${APP_ENV_FILE}"
  output_fail "Script $0 exiting ... "
  output_fail "---------------------------------------------------------------------------"
  output_null
  read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
  exit 1
else
  output_okay "✅ Done."
  output_okay "   Content successfully written to ${APP_PATH}/${APP_ENV_FILE}"
  output_null
fi

# Create Compose File using function from wsl2-lib.sh
CreateNewFile "${APP_PATH}/${APP_COMPOSE}" "Y"
output_info "ℹ️ Writing content to ${APP_COMPOSE}. Please wait ..."
# Write new content to the compose file
cat << EOF > $APP_PATH/$APP_COMPOSE
services:
# OLD MODE → NEW COMPOSE FILE WILL USE POSTGRESQL FROM DB-CLUSTER ;)
#  # ─────────────────────────────────────────────
#  # PostgreSQL Datenbank
#  # ─────────────────────────────────────────────
#  HedgeDocDB:
#    image: postgres:16-alpine
#    container_name: HedgeDocDB
#    environment:
#      - POSTGRES_USER=hedgedoc
#      - POSTGRES_PASSWORD=H3dg3D0cS3cur34dminPWD
#      - POSTGRES_DB=hedgedoc
#    volumes:
#      # Persistenter Speicher: lokales Bind-Mount statt anonymes Docker-Volume
#      - \${APP_PATH}/database:/var/lib/postgresql/data
#    restart: unless-stopped
#    networks:
#      - hedgedoc-net
#      - apphost

  # ─────────────────────────────────────────────
  # HedgeDoc App
  # ─────────────────────────────────────────────
  ${APP_SERVICE}:
    image: quay.io/hedgedoc/hedgedoc:latest
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

    environment:
      # Datenbank-Verbindung (Sondereichen müssen URL-Konform sein!)
      - CMD_DB_URL=\${CMD_DB_URL}

      # Domain/IP: Hier die IP deines WSL2-Netzwerkadapters oder "localhost"
      # Für reinen Lokal-Zugriff von Windows aus: localhost
      - CMD_DOMAIN=\${CMD_DOMAIN}
      - CMD_PORT=${APP_PORT}
      - CMD_URL_ADDPORT=true
      - CMD_PROTOCOL_USESSL=false

      # Produktionsmodus
      - NODE_ENV=production

      # Sicherheitseinstellungen (kannst du nach Bedarf anpassen)
      - CMD_ALLOW_ANONYMOUS=false          # Kein anonymer Zugriff
      - CMD_ALLOW_ANONYMOUS_EDITS=false    # Keine anonymen Bearbeitungen
      - CMD_DEFAULT_PERMISSION=private     # Neue Notes sind privat
      - CMD_ALLOW_EMAIL_REGISTER=true      # Registrierung per E-Mail erlauben
      - CMD_ALLOW_GRAVATAR=false           # Gravatar deaktivieren

      # Session-Secret (bitte durch einen zufälligen String ersetzen!)
      - CMD_SESSION_SECRET=tcBuVMTLRmLKEoWhjTsAHBiMaFEJRWDzzyZkez

    ports:
      # Port-Mapping: Windows-Port ${APP_PORT} → Container-Port 3010
      - "${APP_PORT}:${TCP_PORT}"

    networks:
      apphost:
        ipv4_address: ${APP_IP}
      db-cluster:
        ipv4_address: ${SQL_IP}

    volumes:
      # Persistenter Speicher für hochgeladene Dateien/Bilder
      - ${MOUNT_POINT}:/hedgedoc/public/uploads

#    depends_on:
#      - HedgeDocDB

# ─────────────────────────────────────────────
# Internes Netzwerk für DB ↔ App Kommunikation
# ─────────────────────────────────────────────
networks:
  apphost:
    external: true
  db-cluster:
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
