#!/usr/bin/env bash
# This Shell Script will install & configure the following App: DbGate
# URL: https://github.com/hhftechnology/Dock-Dploy
# Place this script in /usr/local/bin make it executable and run it with sudo privileges
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
# TEST RESULTS:  SUCCESSFULLY TESTED ON WSL2/DEBIAN ON 09.06.2026
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
# Script Name:   install-dbgate.sh
# Last Update:   09.06.2026
# Written by:    Praetoriani
# Website:       https://github.com/praetoriani
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆

# Load the WSL2 Library (important for this script)
CurrentScriptLocation="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"         # ← Gets the full path to the current location
source $CurrentScriptLocation/dockbay.lib.sh

# START WITH A CLEAN CONSOLE
clear

# SET THE INSTALLATION DIRECTORY (SILENTLY) BASED ON THE APP-TYPE
SetupLocationConfig "sql"

# Get the IP-Address of the WSL2/Debian Instance
HOST_IP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# THE FOLOWING SECTION IS A SET OF SCRIPT VARIABLES WHICH ARE USED TO CONFIGURE THE INSTALLATION OF THE DOCKER CONTAINER
CURRENT_USER=$(whoami)                              # This is the current user (who executed this script)
#------------------------------------------------------------------------------------------------------------------------------------------------------
# MAIN DOCKER CONFIGURATION
APP_FULL_NAME="DBGate"                              # Full name of the App that will be installed (only used for console output)
APP_NAME="dbgate"                                   # The folder name of the App (do not use spaces! only use lowercase and - or _ )
APP_SERVICE="DBGate"                                # The Name of the Service (Container Name) for the Compose File
APP_COMPOSE="${APP_NAME}-compose.yml"               # The name of the Docker Compose file (do not change this!)
DOCKERDIR="${DOCKBAY["ROOTPATH"]}"                  # Absolute path to the root directory of the docker stacks
if [ "$SETUP_LOCATION" = "EMPTY"]; then
  APP_PATH="${DOCKBAY["SQLSTACK"]}/${APP_NAME}"     # Absolute path to the Installation Directory
else
  APP_PATH="${SETUP_LOCATION}/${APP_NAME}"          # Absolute path to the Installation Directory
fi
#------------------------------------------------------------------------------------------------------------------------------------------------------
# ADDITIONAL CONFIGURATION
APP_ENV_FILE=".env"                                 # The name of the .env-file for the Docker Compose File
#------------------------------------------------------------------------------------------------------------------------------------------------------
# SSL & AUTH CONFIGURATION
SQL_USER="dbg-admin"                                # The Username for the default admin account ← CHANGE THIS!!
SQL_PASS="ZCM6Mjy7m5G5jX"                           # The Password for the default admin account ← CHANGE THIS!!
#------------------------------------------------------------------------------------------------------------------------------------------------------
# NETWORK CONFIGURATION
APP_PORT="3333"                                     # This is the Port Number which will be exposed for public access
TCP_PORT="3000"                                     # This is the Port Number the Docker Container uses internally
APP_IP="172.22.0.4"                                 # The (fixed) IP for the Docker Container (Gateway must already exist!)
SQL_IP="172.30.1.1"                                 # The (fixed) IP for the nginx-proxy Network
#------------------------------------------------------------------------------------------------------------------------------------------------------
# VOLUME & LOCAL MOUNT POINTS
DATA_VOLUME="DBGateData"                            # Name of the Docker Volume -> Only needed if app needs a Docker Volume!


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

# Create .env File using function from wsl2-lib.sh
CreateNewFile "${APP_PATH}/${APP_ENV_FILE}" "Y"

# Write new content to the .env file
output_info "ℹ️ Writing content to ${APP_PATH}/${APP_ENV_FILE}. Please wait ..."
cat << EOF > $APP_PATH/$APP_ENV_FILE
# ─────────────────────────────────────────
#  DbGate – Umgebungsvariablen
# ─────────────────────────────────────────
APP_IP=${APP_IP}
SQL_IP=${SQL_IP}
# Host-Port, auf dem DbGate erreichbar sein soll
APP_PORT=${APP_PORT}
TCP_PORT=${TCP_PORT}
DBGUSER=${SQL_USER}
DBGPASS=${SQL_PASS}
# ── MariaDB Verbindung ───────────────────
# Container-Name oder IP deines MariaDB-Containers
MARIADB_HOST=MariaDB-Host
MARIADB_PORT=3306
MARIADB_USER=root
MARIADB_PASSWORD=Xg!8vQ-S9hYeV5Xe
MARIADB_LABEL=MariaDB Host

# ── PostgreSQL Verbindung ────────────────
# Container-Name oder IP deines PostgreSQL-Containers
POSTGRES_HOST=PostgreSQL-Host
POSTGRES_PORT=5432
POSTGRES_USER=postgres_admin
POSTGRES_PASSWORD=P6k.5D!9FvCq#hW+Tk
POSTGRES_LABEL=PostgreSQL Host

# ── MongoDB Verbindung ───────────────────
# Container-Name oder IP deines PostgreSQL-Containers
MONGODB_HOST=MongoDB
MONGODB_PORT=27017
MONGODB_USER=mdb-admin
MONGODB_PASSWORD=e0nCph1k6XXnNV
MONGODB_LABEL=MongoDB Host
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

# Creating new Docker Volume using function from wsl2-lib.sh
CreateNewDockerVolume $DATA_VOLUME $APP_NAME

# Create Compose File using function from wsl2-lib.sh
CreateNewFile "${APP_PATH}/${APP_COMPOSE}" "Y"

output_info "ℹ️ Writing content to ${APP_COMPOSE}. Please wait ..."
# Write new content to the compose file
cat << 'EOF' > $APP_PATH/$APP_COMPOSE
# -----------------------------------------------------------------------------
#  DbGate – Docker Compose
#  Netzwerke: db-cluster (Datenbankzugriff) + apphost (Web-Zugriff)
# -----------------------------------------------------------------------------

services:
  DBGate:
    image: dbgate/dbgate:latest
    container_name: DBGate
    restart: unless-stopped

    ports:
      - "${APP_PORT}:${TCP_PORT}"

    volumes:
      # Persistenz für gespeicherte Skripte, Verbindungen (manuell hinzugefügte),
      # Archive und Einstellungen
      - DBGateData:/root/.dbgate

    environment:
      LANGUAGE: de
      WEB_ROOT: /dbadmin
      LOGIN:    ${DBGUSER}
      PASSWORD: ${DBGPASS}
      # -- Vordefinierte Verbindungen ------------------------------------------
      # Kommagetrennte Liste der Verbindungs-IDs (frei wählbare Bezeichner)
      CONNECTIONS: "mariadb_connex,postgres_connex,mongodb_connex"

      # -- MariaDB / MySQL Verbindung ------------------------------------------
      LABEL_mariadb_connex:    "${MARIADB_LABEL}"
      SERVER_mariadb_connex:   "${MARIADB_HOST}"
      PORT_mariadb_connex:     "${MARIADB_PORT}"
      USER_mariadb_connex:     "${MARIADB_USER}"
      PASSWORD_mariadb_connex: "${MARIADB_PASSWORD}"
      # MariaDB nutzt das mysql-Plugin (vollständig kompatibel)
      ENGINE_mariadb_connex:   "mysql@dbgate-plugin-mysql"

      # -- PostgreSQL Verbindung -----------------------------------------------
      LABEL_postgres_connex:    "${POSTGRES_LABEL}"
      SERVER_postgres_connex:   "${POSTGRES_HOST}"
      PORT_postgres_connex:     "${POSTGRES_PORT}"
      USER_postgres_connex:     "${POSTGRES_USER}"
      PASSWORD_postgres_connex: "${POSTGRES_PASSWORD}"
      ENGINE_postgres_connex:   "postgres@dbgate-plugin-postgres"

      # -- MongoDB Verbindung --------------------------------------------------
      LABEL_mongodb_connex:    "${MONGODB_LABEL}"
      SERVER_mongodb_connex:   "${MONGODB_HOST}"
      PORT_mongodb_connex:     "${MONGODB_PORT}"
      USER_mongodb_connex:     "${MONGODB_USER}"
      PASSWORD_mongodb_connex: "${MONGODB_PASSWORD}"
      # MariaDB nutzt das mysql-Plugin (vollständig kompatibel)
      ENGINE_mongodb_connex:   "mongo@dbgate-plugin-mongo"


    networks:
      system-core:
        ipv4_address: ${APP_IP}
      db-cluster:
        ipv4_address: ${SQL_IP}

# -----------------------------------------------------------------------------
#  Volumes
# -----------------------------------------------------------------------------
volumes:
  DBGateData:
    external: true

# -----------------------------------------------------------------------------
#  Netzwerke – als EXTERN deklarieren, da sie bereits existieren
# -----------------------------------------------------------------------------
networks:
  system-core:
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
output_info "Note: This Container WILL NOT be handled by Traefik!"
output_null
output_note "💡 Please Note:"
output_note "You can access the Admin Board with the following info:"
output_note "URL:   http://localhost:${APP_PORT}/dbadmin"
output_note "User:  ${SQL_USER}"
output_note "Pass:  ${SQL_PASS}"
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
# Go to the directory where the docker-compose.yml file is located
cd /opt/docker/sysapp/dbgate && docker compose up -d

# View logs
docker compose logs -f DBGate

# Stop container
docker stop DBGate

# Start container
docker start DBGate

# Remove container
docker rm -f DBGate
INFO
