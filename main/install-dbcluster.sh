#!/usr/bin/env bash
# This Shell Script will install & configure the Docker DB-Cluster
# The DB-Cluster includes the following Databse Engines (as Docker Container)
# - MariaDB
# - PostgreSQL
# - MongoDB
# - DBGate (Database Manager)
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
# Test Results:    ✓ Verified working
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
# Script Name:   install-etherpad.sh
# Last Update:   20.06.2026
# Written by:    Praetoriani
# Website:       https://github.com/praetoriani
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆


################################################################################
# 
# !!  IMPORTANT INFORMATION  !!
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
# CURRENTLY WE HAVE IMPLEMENTED THE ONLY SOURCE OF TRUTH (setup.config.json)
# AND WE IMPLEMENTED A PASSWORD-SOLUTION TO (OPTIONALLY) CREATE USER-BASED
# LOGIN-CREDENTIALS FOR EACH APPLICATION.
# 
# WE STILL NEED TO IMPLEMENT A FUNCTION THAT RUNS AFTER EACH INSTALLATION AND
# VERIFIES THAT EVERYTHING WAS SUCCESSFULLY DONE, SO WE CAN STORE THE RESULTS
# IN OUR ONLY SOURCE OF TRUTH:  setup.config.json
# DUE TO WE NEED THIS IN ALMOST EVERY INSTALLATION PROCESS, IT WOULD BE A GOOD
# IDEA TO PUT THIS FUNCTION INSIDE  dockbay.lib.sh !!
#
# AND THERE IS ANOTHER ISSUE, WE STILL NEED TO SOLVE!!
# WETHER WE'RE GOING TO USE DEFAULT CREDENTIALS OR USER-BASED CREDENTIALS, ...
# WE NEED A PLACE/FILE (json?) WHERE WE GONNA STORE ALL THOSE ACCOUNT INFOS!
# WE DEFINITELY NEED AN OPTION TO MANAGE ALL THESE USER CREDENTIAL INFORMAIONS!
# THIS SHOULD BE ALSO DEFINED INSIDE  dockbay.lib.sh !!
# 
################################################################################


# Load the WSL2 Library (important for this script)
CurrentScriptLocation="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"         # ← Gets the full path to the current location
source $CurrentScriptLocation/dockbay.lib.sh
source $CurrentScriptLocation/credentials.lib.sh                              # ← Reuired Library to create user based login credentials

set -euo pipefail

# START WITH A CLEAN CONSOLE
clear

# Get the IP-Address of the WSL2/Debian Instance
HOST_IP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# THE FOLOWING SECTION IS A SET OF SCRIPT VARIABLES WHICH ARE USED TO CONFIGURE THE INSTALLATION OF THE DOCKER CONTAINER
CURRENT_USER=$(whoami)                                         # This is the current user (who executed this script)
#------------------------------------------------------------------------------------------------------------------------------------------------------
# MAIN DOCKER CONFIGURATION
APP_FULL_NAME="Docker DB-Cluster"                              # Full name of the App that will be installed (only used for console output)
#------------------------------------------------------------------------------------------------------------------------------------------------------
# MARIA DB CONFIGURATION
MDB_APP_NAME="MariaDB-Host"                                    # The name of the Container (also used as foldername for the compose project)
MDB_APP_SERVICE="mariadb"                                      # The name of the Service inside the Compose File
MDB_APP_PATH="${DOCKBAY["SQLSTACK"]}/${MDB_APP_SERVICE}"       # The full path to the installation directory
MDB_COMPOSE="${MDB_APP_SERVICE}-compose.yml"                   # The name of the Docker Compose file (do not change this!)
MDB_APP_PORT="3306"                                            # The exposed port that will be used to access the container
MDB_SQL_IP="172.30.2.1"                                        # The fixed IP for the db-cluster Network
MDB_SUBFOLDERS=("config" "init" "data")                        # Array that holds all Names of the Subfolders
MDB_CONF_FILE="/config/custom.cnf"                             # Internal path to the custom config file
MDB_INIT_FILE="/init/01-init.sql"                              # Internal path to the SQL init script
MDB_USER="mariadb_user"                                        # The DB-User for regular access
MDB_PASS="S9-hYeXg!8vQ+XeV5"                                   # The Password for the DB-User
MDB_ROOT="Xg!8vQ-S9hYeV5Xe"                                    # Password for the root-User
#------------------------------------------------------------------------------------------------------------------------------------------------------
# POSTGRESQL DB CONFIGURATION
PDB_APP_NAME="PostgreSQL-Host"                                 # The name of the Container (also used as foldername for the compose project)
PDB_APP_SERVICE="postgresql"                                   # The name of the Service inside the Compose File
PDB_APP_PATH="${DOCKBAY["SQLSTACK"]}/${PDB_APP_SERVICE}"       # The full path to the installation directory
PDB_COMPOSE="${PDB_APP_SERVICE}-compose.yml"                   # The name of the Docker Compose file (do not change this!)
PDB_APP_PORT="5432"                                            # The exposed port that will be used to access the container
PDB_SQL_IP="172.30.2.2"                                        # The fixed IP for the db-cluster Network
PDB_SUBFOLDERS=("config" "init" "data")                        # Array that holds all Names of the Subfolders
PDB_CNF1_FILE="/config/postgresql.conf"                        # Internal path to the custom config file
PDB_CNF2_FILE="/config/pg_hba.conf"                            # Internal path to the custom config file
PDB_INIT_FILE="/init/01-init.sql"                              # Internal path to the SQL init script
PDB_USER="postgres_admin"                                      # The PostgreSQL Root User
PDB_PASS="P6k.5D!9FvCq#hW+Tk"                                  # The Password for the PostgreSQL Root User
#------------------------------------------------------------------------------------------------------------------------------------------------------
# MONGO DB CONFIGURATION
MONGO_APP_NAME="MongoDB"                                       # The name of the Container (also used as foldername for the compose project)
MONGO_APP_SERVICE="mogodb"                                     # The name of the Service inside the Compose File
MONGO_APP_PATH="${DOCKBAY["SQLSTACK"]}/${MONGO_APP_SERVICE}"   # The full path to the installation directory
MONGO_COMPOSE="${MONGO_APP_SERVICE}-compose.yml"               # The name of the Docker Compose file (do not change this!)
MONGO_APP_PORT="27017"                                         # The exposed port that will be used to access the container
MONGO_SQL_IP="172.30.2.3"                                      # The fixed IP for the db-cluster Network
MONGO_SUBFOLDERS=("dbdata" "config")                           # Array that holds all Names of the Subfolders
MONGO_CONF_FILE="/config/custom.cnf"                           # Internal path to the custom config file
MONGO_INIT_FILE="/init/01-init.sql"                            # Internal path to the SQL init script
MONGO_USER="mdb-admin"                                         # The DB-User for regular access
MONGO_PASS="e0nCph1k6XXnNV"                                    # The Password for the DB-User
#------------------------------------------------------------------------------------------------------------------------------------------------------
# DBGATE CONFIGURATION
DBGATE_APP_NAME="DBGate"                                        # The name of the Container (also used as foldername for the compose project)
DBGATE_APP_SERVICE="dbgate"                                     # The name of the Service inside the Compose File
DBGATE_APP_PATH="${DOCKBAY["SQLSTACK"]}/${DBGATE_APP_SERVICE}"  # The full path to the installation directory
DBGATE_COMPOSE="${DBGATE_APP_SERVICE}-compose.yml"              # The name of the Docker Compose file (do not change this!)
DBGATE_ENV="${DBGATE_APP_PATH}/.env"                            # The name of the .env
DBGATE_APP_PORT="3333"                                          # The exposed port that will be used to access the container
DBGATE_TCP_PORT="3000"                                          # The internal TCP port of the Container
DBGATE_APP_IP="172.22.0.4"                                      # The fixed IP for the apphost Network
DBGATE_SQL_IP="172.30.1.1"                                      # The fixed IP for the db-cluster Network
DBGATE_USER="dbg-admin"                                         # The DB-User for regular access
DBGATE_PASS="ZCM6Mjy7m5G5jX"                                    # The Password for the DB-User
DBGATE_DATAVOLUME="DBGateData"                                  # Name of the Docker Volume -> Only needed if app needs a Docker Volume!
#------------------------------------------------------------------------------------------------------------------------------------------------------
# ADDITIONAL CONFIGURATION
APP_ENV_FILE=".env"                                         # The name of the .env-file for the Docker Compose File
#------------------------------------------------------------------------------------------------------------------------------------------------------


# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# MANDATORY PRE-CHECKS

output_text "Script $0 started ..."
output_text "********************************************************************************"
output_null
output_text "Checking current configuration. Please wait ..."
output_null
sleep 0.5

checkmariadb="$(jq -r '.setup.msqldbhost' $SETUPCFGJSON)"
checkpostgre="$(jq -r '.setup.psqldbhost' $SETUPCFGJSON)"
checkmongodb="$(jq -r '.setup.mongodbhost' $SETUPCFGJSON)"
checkdbgate="$(jq -r '.app.DBGate' $SETUPCFGJSON)"

# Get current config from global array
if [ "$checkmariadb" = "false" ] && [ "$checkpostgre" = "false" ] && [ "$checkmongodb" = "false" ] && [ "$checkdbgate" = "false" ]; then
    output_text "Required Packages to install:  0"
    sleep 0.2
    output_text "Nothing to install."
    sleep 0.2
    output_text "Going back to Main Screen"
    output_null
    sleep 2.0
    exit 0
else
    stillrequired="Reuired Docker Packages to be installed on your system:"
    if [ "$checkmariadb" = "true" ]; then
      stillrequired="$stillrequired"$'\n'"${RED_BOLD}→  $MDB_APP_NAME ${DARK_GRAY_BOLD}"
    fi
    if [ "$checkpostgre" = "true" ]; then
      stillrequired="$stillrequired"$'\n'"${RED_BOLD}→  $PDB_APP_NAME ${DARK_GRAY_BOLD}"
    fi
    if [ "$checkmongodb" = "true" ]; then
      stillrequired="$stillrequired"$'\n'"${RED_BOLD}→  $MONGO_APP_NAME ${DARK_GRAY_BOLD}"
    fi
    if [ "$checkdbgate" = "true" ]; then
      stillrequired="$stillrequired"$'\n'"${RED_BOLD}→  $DBGATE_APP_NAME ${DARK_GRAY_BOLD}"
    fi
    output_text "Required Packages to install:"
    sleep 0.2
    output_text "${stillrequired}"
    output_null
    sleep 2.0
fi
output_null
output_text "All Packages will be installed one by one."
output_null
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
        output_text "Returning back to Main Screen. Please wait ..."
        sleep 0.5
        clear
        exit 0
        ;;
    c|C)
        clear
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


DEFAULT_LOGIN_CREDENTIALS="NULL"

output_code "${RED_BOLD}🛡️ Security Warning!${NC}"
output_code "${RED_BOLD}The following installation proccess will create numerous login credentials!${NC}"
output_code "${RED_BOLD}You can either use the defalut user account configuration (not recommended)${NC}"
output_code "${RED_BOLD}or you can create your own credentials during installation (recommended).${NC}"
output_null
output_text "Enter one of the following options and hit <enter>"
output_null
output_text "Please press 'd' for default configuration or 'c' to create your own credentials:"

set -euo pipefail
prompt="${DARK_GRAY_BOLD}→ ${NC}"
trap cleanup EXIT

while true; do
  # Print line and delete to end of line (\033[K)
  printf "\r\033[K%b" "$prompt"

  # Read a character without Enter and without echo
  IFS= read -r -n1 -s key

  case "$key" in
    d|D)
        output_null
        output_code "${RED_BOLD}... despite warning, user chose to use default login credentials (not recommended)!${NC}"
        DEFAULT_LOGIN_CREDENTIALS="TRUE"
        sleep 2.0
        clear
        break
        ;;
    c|C)
        output_null
        output_code "${BLUE_BOLD}... user chose recommended way and is going to create own login credentials.${NC}"
        DEFAULT_LOGIN_CREDENTIALS="FALSE"
        sleep 2.0
        clear
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

# ########################################
#
# → MAIN INSTALLATION PROCESS  !!
#
# ########################################




# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# INSTALLATION OF:  MARIA DB
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


if [ "$checkmariadb" = "true" ]; then
  output_info "ℹ️ Starting with Setup & Configuration of ${MDB_APP_NAME} ... "
  output_null
  output_info "ℹ️ Creating Folder Structure ..."
  output_null

  # Create directory structure
  CreateNewPath "${MDB_APP_PATH}" 775 1000
  for foldername in "${MDB_SUBFOLDERS[@]}"; do
    CreateNewPath "${MDB_APP_PATH}/${foldername}" 775 1000
  done
  output_okay "✅ Done."

  # Running SetFolderPermission from wsl2-lib.sh
  SetFolderPermission 777 1000 "${DOCKBAY["SQLSTACK"]}"

  # ======================================================================
  # CREATE USER LOGIN CREDENTIALS (ONLY IF PREVIOUSLY CONFIGURED!)
  # ======================================================================
  if [ "DEFAULT_LOGIN_CREDENTIALS" = "FALSE" ]; then
    output_text "Please create a password for the root-account of MariaDB and hit <enter>"
    MDB_ROOT="$(GetPassword "Enter Password for Root Account (min. 6 chars):")"
    output_okay "✅ Done."
    output_text "Please create default user account for MariaDB and hit <enter>"
    MDB_USER="$(GetUsername "Enter the Username (min. 4 chars):")"
    MDB_PASS="$(GetPassword "Enter the Password (min. 6 chars):")"
    output_okay "✅ Done."
  elif [ "DEFAULT_LOGIN_CREDENTIALS" = "TRUE" ]; then
    output_code "${RED_BOLD}Using default account configurations for MariaDB (based on user input) !!${NC}"
  fi

  output_info "ℹ️ Creating file: ${APP_ENV_FILE}"
  # Create .env File using function from wsl2-lib.sh
  CreateNewFile "${DOCKBAY["SQLSTACK"]}/${APP_ENV_FILE}" "Y"
  # Write new content to the file
  output_info "ℹ️ Writing content to ${APP_ENV_FILE}. Please wait ..."
cat << EOF >> "${DOCKBAY["SQLSTACK"]}/${APP_ENV_FILE}"
# ═══════════════════════════════════════════
# MariaDB Access
# ═══════════════════════════════════════════
MARIADB_ROOT_PASSWORD=${MDB_ROOT}
MARIADB_DATABASE=mariadb_root
MARIADB_USER=${MDB_USER}
MARIADB_PASSWORD=${MDB_PASS}
MARIADB_PORT=${MDB_APP_PORT}

# ═══════════════════════════════════════════
# Timezone (for both DBs)
# ═══════════════════════════════════════════
TZ=Europe/Berlin

EOF
  # Get the file size by using function from wsl2-lib.sh
  # Check if the size is 0 byte
  if [ $(GetFileSize "${DOCKBAY["SQLSTACK"]}/${APP_ENV_FILE}") -eq 0 ]; then
    output_fail "🛑 Failed to write new content to ${APP_ENV_FILE}"
    output_fail "Script $0 exiting ... "
    output_fail "---------------------------------------------------------------------------"
    output_null
    read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
    exit 1
  else
    output_okay "✅ Done."
    output_okay "   Content successfully written to ${APP_ENV_FILE}"
    output_null
  fi

  output_info "ℹ️ Creating file: ${MDB_APP_PATH}${MDB_CONF_FILE}"
  # Create File using function from wsl2-lib.sh
  CreateNewFile "${MDB_APP_PATH}${MDB_CONF_FILE}" "Y"
  # Write new content to the file
  output_info "ℹ️ Writing content to ${MDB_APP_PATH}${MDB_CONF_FILE}"
cat << EOF > $MDB_APP_PATH$MDB_CONF_FILE
[mariadb]
# ── Zeichensatz ─────────────────────────────────────────
character-set-server  = utf8mb4
collation-server      = utf8mb4_unicode_ci

# ── Verbindungen ────────────────────────────────────────
max_connections       = 100
connect_timeout       = 10
wait_timeout          = 600
interactive_timeout   = 600

# ── InnoDB Engine ───────────────────────────────────────
# ~50% des für MariaDB verfügbaren RAM
innodb_buffer_pool_size   = 256M
innodb_log_file_size      = 64M
innodb_flush_log_at_trx_commit = 1
innodb_file_per_table     = ON

# ── Slow Query Log (Dev-Umgebung) ───────────────────────
slow_query_log            = 1
slow_query_log_file       = /var/lib/mysql/slow-queries.log
long_query_time           = 2

# ── Binary Log deaktivieren (spart Platz in Dev) ────────
skip-log-bin

# ── Netzwerk ────────────────────────────────────────────
bind-address              = 0.0.0.0
port                      = ${MDB_APP_PORT}
EOF
  # Get the file size by using function from wsl2-lib.sh
  # Check if the size is 0 byte
  if [ $(GetFileSize "${MDB_APP_PATH}${MDB_CONF_FILE}") -eq 0 ]; then
    output_fail "🛑 Failed to write new content to ${MDB_APP_PATH}${MDB_CONF_FILE}"
    output_fail "Script $0 exiting ... "
    output_fail "---------------------------------------------------------------------------"
    output_null
    read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
    exit 1
  else
    output_okay "✅ Done."
    output_okay "   Content successfully written to ${MDB_APP_PATH}${MDB_CONF_FILE}"
    output_null
  fi
  output_info "ℹ️ Creating file: ${MDB_APP_PATH}${MDB_INIT_FILE}"
  # Create File using function from wsl2-lib.sh
  CreateNewFile "${MDB_APP_PATH}${MDB_INIT_FILE}" "Y"
  # Write new content to the file
  output_info "ℹ️ Writing content to ${MDB_APP_PATH}${MDB_INIT_FILE}"
cat << 'EOF' > $MDB_APP_PATH$MDB_INIT_FILE
-- ═══════════════════════════════════════════════════════
-- MariaDB: Initialisierungsskript (nur beim 1. Start)
-- ═══════════════════════════════════════════════════════

-- Entwicklungsdatenbank
CREATE DATABASE IF NOT EXISTS `DevDB`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- App-Datenbank (für installierte Apps)
CREATE DATABASE IF NOT EXISTS `NginxProxyDB`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS `PassboltDB`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS `UptimeKuma`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Berechtigungen für den Standard-App-User
GRANT ALL PRIVILEGES ON `DevDB`.*  TO 'mariadb_user'@'%';
GRANT ALL PRIVILEGES ON `NginxProxyDB`.*  TO 'mariadb_user'@'%';
GRANT ALL PRIVILEGES ON `PassboltDB`.*  TO 'mariadb_user'@'%';
GRANT ALL PRIVILEGES ON `UptimeKuma`.*  TO 'mariadb_user'@'%';

-- Read-Only Benutzer (z.B. für Monitoring/Reporting)
CREATE USER IF NOT EXISTS 'mariadb_ro'@'%' IDENTIFIED BY 'mDB-ReadOnly!';
GRANT SELECT ON `DevDB`.* TO 'mariadb_ro'@'%';
GRANT SELECT ON `NginxProxyDB`.* TO 'mariadb_ro'@'%';
GRANT SELECT ON `PassboltDB`.* TO 'mariadb_ro'@'%';
GRANT SELECT ON `UptimeKuma`.* TO 'mariadb_ro'@'%';

FLUSH PRIVILEGES;
EOF
  # Get the file size by using function from wsl2-lib.sh
  # Check if the size is 0 byte
  if [ $(GetFileSize "${MDB_APP_PATH}${MDB_INIT_FILE}") -eq 0 ]; then
    output_fail "🛑 Failed to write new content to ${MDB_APP_PATH}${MDB_INIT_FILE}"
    output_fail "Script $0 exiting ... "
    output_fail "---------------------------------------------------------------------------"
    output_null
    read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
    exit 1
  else
    output_okay "✅ Done."
    output_okay "   Content successfully written to ${MDB_APP_PATH}${MDB_INIT_FILE}"
    output_null
  fi
  
  # Create Compose File using function from wsl2-lib.sh
  CreateNewFile "${DOCKBAY["SQLSTACK"]}/${MDB_COMPOSE}" "Y"
  # Write new content to the compose file
  output_info "ℹ️ Writing content to ${MDB_COMPOSE}. Please wait ..."
cat << EOF > "${DOCKBAY["SQLSTACK"]}/${MDB_COMPOSE}"
# ═══════════════════════════════════════════════════════════════
# /opt/docker/dbhost/docker-compose.yml
# MariaDB + PostgreSQL im gemeinsamen db-cluster Netzwerk
# ═══════════════════════════════════════════════════════════════

services:

  # ─────────────────────────────────────────────────────────────
  # MariaDB 11.4 LTS
  # ─────────────────────────────────────────────────────────────
  ${MDB_APP_SERVICE}:
    image: mariadb:11.4
    container_name: ${MDB_APP_NAME}
    restart: unless-stopped

    environment:
      MARIADB_ROOT_PASSWORD: \${MARIADB_ROOT_PASSWORD}
      MARIADB_DATABASE:      \${MARIADB_DATABASE}
      MARIADB_USER:          \${MARIADB_USER}
      MARIADB_PASSWORD:      \${MARIADB_PASSWORD}
      TZ:                    \${TZ}

    volumes:
      - ./mariadb/data:/var/lib/mysql
      - ./mariadb/config/custom.cnf:/etc/mysql/conf.d/custom.cnf:ro
      - ./mariadb/init:/docker-entrypoint-initdb.d:ro

    # expose: Nur interner Docker-Zugriff (kein Host-Port-Mapping!)
    # Für lokalen Zugriff vom Host (z.B. DBeaver): auskommentierten
    # Port-Block aktivieren
    expose:
      - "${MDB_APP_PORT}"
    ports:
      - "127.0.0.1:${MDB_APP_PORT}:${MDB_APP_PORT}"   # ← Aktivieren für Host-Zugriff

    networks:
      db-cluster:
        ipv4_address: ${MDB_SQL_IP}

    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      interval: 15s
      timeout: 5s
      retries: 5
      start_period: 45s

    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 128M

    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

# ═══════════════════════════════════════════════════════════════
# NETZWERK: db-cluster
# attachable: true → andere Compose-Projekte können sich verbinden
# ═══════════════════════════════════════════════════════════════
networks:
  db-cluster:
    external: true
EOF
  # Get the file size by using function from wsl2-lib.sh
  # Check if the size is 0 byte
  if [ $(GetFileSize "${DOCKBAY["SQLSTACK"]}/${MDB_COMPOSE}") -eq 0 ]; then
    output_fail "🛑 Failed to write new content to ${MDB_COMPOSE}"
    output_fail "Script $0 exiting ... "
    output_fail "---------------------------------------------------------------------------"
    output_null
    read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
    exit 1
  else
    output_okay "✅ Done."
    output_okay "   Content successfully written to ${MDB_COMPOSE}"
    output_null
  fi
  
  # Running RestartDockerDaemon from wsl2-lib.sh
  RestartDockerDaemon
  
  output_info "ℹ️ Trying to start Docker Container:  ${MDB_APP_NAME}"
  docker compose -f "${DOCKBAY["SQLSTACK"]}/${MDB_COMPOSE}" up -d
  # Check if the Container could be created and is running
  if [ "$(CheckContainer "${MDB_APP_NAME}")" = "ok" ]; then
    # update the json file
    jq '.setup.msqldbhost = false' $SETUPCFGJSON > $SETUPTMPJSON && mv $SETUPTMPJSON $SETUPCFGJSON
    # update global array
    new_packages=()
    for p in "${DBCLUSTER_PKG[@]}"; do
        if [[ "$p" != "$pkg" ]]; then
            new_packages+=("$p")
        fi
    done
    DBCLUSTER_PKG=("${new_packages[@]}")

    if [ "$(ContainerStatus "${MDB_APP_NAME}")" = "ok" ]; then
      output_okay "✅ Done."
      output_okay "   ${MDB_APP_NAME} successfully created and started"
      output_null
    else
      output_fail "🛑 Failed to start Docker Container for:  ${MDB_APP_NAME}"
      output_fail "The Container was created but could not be started!"
      output_fail "Please start the Container manually!"
      output_null
    fi
  else
    output_fail "🛑 Failed to create Docker Container for:  ${MDB_APP_NAME}"
    output_fail "Script $0 exiting ... "
    output_fail "---------------------------------------------------------------------------"
    output_null
    read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
    exit 1
  fi
fi



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# INSTALLATION OF:  POSTGRE-SQL
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


if [ "$checkpostgre" = "true" ]; then
  output_info "ℹ️ Starting with Setup & Configuration of ${PDB_APP_NAME} ... "
  output_null
  output_info "ℹ️ Creating Folder Structure ..."
  output_null

  # Create directory structure
  CreateNewPath "${PDB_APP_PATH}" 775 1000
  for foldername in "${PDB_SUBFOLDERS[@]}"; do
    CreateNewPath "${PDB_APP_PATH}/${foldername}" 775 1000
  done
  output_okay "✅ Done."

  # Running SetFolderPermission from wsl2-lib.sh
  SetFolderPermission 777 1000 "${DOCKBAY["SQLSTACK"]}"

  # ======================================================================
  # CREATE USER LOGIN CREDENTIALS (ONLY IF PREVIOUSLY CONFIGURED!)
  # ======================================================================
  if [ "DEFAULT_LOGIN_CREDENTIALS" = "FALSE" ]; then
    output_text "Please create a password for the root-account of MariaDB and hit <enter>"
    MDB_ROOT="$(GetPassword "Enter Password for Root Account (min. 6 chars):")"
    output_okay "✅ Done."
    output_text "Please create default user account for MariaDB and hit <enter>"
    MDB_USER="$(GetUsername "Enter the Username (min. 4 chars):")"
    MDB_PASS="$(GetPassword "Enter the Password (min. 6 chars):")"
    output_okay "✅ Done."
  elif [ "DEFAULT_LOGIN_CREDENTIALS" = "TRUE" ]; then
    output_code "${RED_BOLD}Using default account configurations for MariaDB (based on user input) !!${NC}"
  fi

  output_info "ℹ️ Creating file: ${APP_ENV_FILE}"
  # Create .env File using function from wsl2-lib.sh
  CreateNewFile "${DOCKBAY["SQLSTACK"]}/${APP_ENV_FILE}" "Y"
  # Write new content to the file
  output_info "ℹ️ Writing content to ${APP_ENV_FILE}. Please wait ..."
cat << EOF >> "${DOCKBAY["SQLSTACK"]}/${APP_ENV_FILE}"
# ═══════════════════════════════════════════
# PostgreSQL Access
# ═══════════════════════════════════════════
POSTGRES_USER=${PDB_USER}
POSTGRES_PASSWORD=${PDB_PASS}
POSTGRES_DB=postgres_root
PGSQLDB_PORT=${PDB_APP_PORT}

EOF
  # Get the file size by using function from wsl2-lib.sh
  # Check if the size is 0 byte
  if [ $(GetFileSize "${DOCKBAY["SQLSTACK"]}/${APP_ENV_FILE}") -eq 0 ]; then
    output_fail "🛑 Failed to write new content to ${APP_ENV_FILE}"
    output_fail "Script $0 exiting ... "
    output_fail "---------------------------------------------------------------------------"
    output_null
    read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
    exit 1
  else
    output_okay "✅ Done."
    output_okay "   Content successfully written to ${APP_ENV_FILE}"
    output_null
  fi

  output_info "ℹ️ Creating file: ${PDB_APP_PATH}${PDB_CNF1_FILE}"
  # Create File using function from wsl2-lib.sh
  CreateNewFile "${PDB_APP_PATH}${PDB_CNF1_FILE}" "Y"
  # Write new content to the file
  output_info "ℹ️ Writing content to ${PDB_APP_PATH}${PDB_CNF1_FILE}"
cat << EOF > $PDB_APP_PATH$PDB_CNF1_FILE
# ── Netzwerk ────────────────────────────────────────────
listen_addresses          = '*'
port                      = ${PDB_APP_PORT}

# ── Verbindungen ────────────────────────────────────────
max_connections           = 100

# ── Speicher ────────────────────────────────────────────
shared_buffers            = 256MB
effective_cache_size      = 512MB
work_mem                  = 16MB
maintenance_work_mem      = 64MB
dynamic_shared_memory_type = posix

# ── Write-Ahead Log ─────────────────────────────────────
wal_level                 = replica
max_wal_size              = 1GB
min_wal_size              = 80MB
checkpoint_completion_target = 0.7

# ── Query Planner ───────────────────────────────────────
default_statistics_target = 100
random_page_cost          = 1.1

# ── Logging ─────────────────────────────────────────────
logging_collector         = on
log_directory             = 'pg_log'
log_filename              = 'postgresql-%Y-%m-%d.log'
log_rotation_age          = 1d
log_rotation_size         = 100MB
log_min_duration_statement = 1000
log_line_prefix           = '%t [%p]: [%l-1] db=%d,user=%u '
log_checkpoints           = on
log_connections           = off
log_disconnections        = off
log_lock_waits            = on

# ── Timezone ────────────────────────────────────────────
timezone                  = 'Europe/Berlin'
log_timezone              = 'Europe/Berlin'

# ── Locale & Encoding ───────────────────────────────────
client_encoding           = UTF8
lc_messages               = 'en_US.utf8'
lc_monetary               = 'en_US.utf8'
lc_numeric                = 'en_US.utf8'
lc_time                   = 'en_US.utf8'
EOF
  # Get the file size by using function from wsl2-lib.sh
  # Check if the size is 0 byte
  if [ $(GetFileSize "${PDB_APP_PATH}${PDB_CNF1_FILE}") -eq 0 ]; then
    output_fail "🛑 Failed to write new content to ${PDB_APP_PATH}${PDB_CNF1_FILE}"
    output_fail "Script $0 exiting ... "
    output_fail "---------------------------------------------------------------------------"
    output_null
    read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
    exit 1
  else
    output_okay "✅ Done."
    output_okay "   Content successfully written to ${PDB_APP_PATH}${PDB_CNF1_FILE}"
    output_null
  fi

  output_info "ℹ️ Creating file: ${PDB_APP_PATH}${PDB_CNF2_FILE}"
  # Create File using function from wsl2-lib.sh
  CreateNewFile "${PDB_APP_PATH}${PDB_CNF2_FILE}" "Y"
  # Write new content to the file
  output_info "ℹ️ Writing content to ${PDB_APP_PATH}${PDB_CNF2_FILE}"
cat << EOF > $PDB_APP_PATH$PDB_CNF2_FILE
# TYPE   DATABASE   USER       ADDRESS           METHOD
# ── Lokale Verbindungen ─────────────────────────────────
local    all        all                          trust
host     all        all        127.0.0.1/32      md5
host     all        all        ::1/128           md5

# ── Docker-Netzwerk (db-cluster: 172.16.0.0/12) ─────────
# Erlaubt Verbindungen von allen Containern im db-cluster
host     all        all        172.16.0.0/12     md5

# ── Replication (für spätere Erweiterungen) ─────────────
# host   replication all       127.0.0.1/32      md5
EOF
  # Get the file size by using function from wsl2-lib.sh
  # Check if the size is 0 byte
  if [ $(GetFileSize "${PDB_APP_PATH}${PDB_CNF2_FILE}") -eq 0 ]; then
    output_fail "🛑 Failed to write new content to ${PDB_APP_PATH}${PDB_CNF2_FILE}"
    output_fail "Script $0 exiting ... "
    output_fail "---------------------------------------------------------------------------"
    output_null
    read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
    exit 1
  else
    output_okay "✅ Done."
    output_okay "   Content successfully written to ${PDB_APP_PATH}${PDB_CNF2_FILE}"
    output_null
  fi

  output_info "ℹ️ Creating file: ${PDB_APP_PATH}${PDB_INIT_FILE}"
  # Create File using function from wsl2-lib.sh
  CreateNewFile "${PDB_APP_PATH}${PDB_INIT_FILE}" "Y"
  # Write new content to the file
  output_info "ℹ️ Writing content to ${PDB_APP_PATH}${PDB_INIT_FILE}"
cat << EOF > $PDB_APP_PATH$PDB_INIT_FILE
-- ═══════════════════════════════════════════════════════
-- PostgreSQL: Initialisierungsskript (nur beim 1. Start)
-- ═══════════════════════════════════════════════════════

-- Nützliche Extensions aktivieren
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";      -- UUID-Generierung
CREATE EXTENSION IF NOT EXISTS "pg_trgm";        -- Trigram-Suche / ILIKE-Optimierung
CREATE EXTENSION IF NOT EXISTS "btree_gin";      -- GIN-Index für B-Tree-Ops
CREATE EXTENSION IF NOT EXISTS "pgcrypto";       -- Kryptographie-Funktionen

-- Dev-Datenbank anlegen
CREATE DATABASE DevDB
    WITH
    OWNER       = ${PDB_USER}
    ENCODING    = 'UTF8'
    LC_COLLATE  = 'en_US.utf8'
    LC_CTYPE    = 'en_US.utf8'
    TEMPLATE    = template0;

-- App-Datenbank anlegen
CREATE DATABASE BlinkoDB
    WITH
    OWNER       = ${PDB_USER}
    ENCODING    = 'UTF8'
    LC_COLLATE  = 'en_US.utf8'
    LC_CTYPE    = 'en_US.utf8'
    TEMPLATE    = template0;

CREATE DATABASE DockhandDB
    WITH
    OWNER       = ${PDB_USER}
    ENCODING    = 'UTF8'
    LC_COLLATE  = 'en_US.utf8'
    LC_CTYPE    = 'en_US.utf8'
    TEMPLATE    = template0;

CREATE DATABASE EtherpadDB
    WITH
    OWNER       = ${PDB_USER}
    ENCODING    = 'UTF8'
    LC_COLLATE  = 'en_US.utf8'
    LC_CTYPE    = 'en_US.utf8'
    TEMPLATE    = template0;

CREATE DATABASE HedgeDocDB
    WITH
    OWNER       = ${PDB_USER}
    ENCODING    = 'UTF8'
    LC_COLLATE  = 'en_US.utf8'
    LC_CTYPE    = 'en_US.utf8'
    TEMPLATE    = template0;

CREATE DATABASE PlankanbanDB
    WITH
    OWNER       = ${PDB_USER}
    ENCODING    = 'UTF8'
    LC_COLLATE  = 'en_US.utf8'
    LC_CTYPE    = 'en_US.utf8'
    TEMPLATE    = template0;

CREATE DATABASE dockhand
    WITH
    OWNER       = ${PDB_USER}
    ENCODING    = 'UTF8'
    LC_COLLATE  = 'en_US.utf8'
    LC_CTYPE    = 'en_US.utf8'
    TEMPLATE    = template0;

-- Separaten App-Benutzer anlegen (kein Superuser!)
CREATE USER psqlUser WITH
    PASSWORD    'My1stPassw0rd!'
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    LOGIN;

-- Berechtigungen zuweisen
GRANT ALL PRIVILEGES ON DATABASE DevDB TO psqlUser;
GRANT ALL PRIVILEGES ON DATABASE BlinkoDB TO psqlUser;
GRANT ALL PRIVILEGES ON DATABASE DockhandDB TO psqlUser;
GRANT ALL PRIVILEGES ON DATABASE EtherpadDB TO psqlUser;
GRANT ALL PRIVILEGES ON DATABASE HedgeDocDB TO psqlUser;
GRANT ALL PRIVILEGES ON DATABASE PlankanbanDB TO psqlUser;
GRANT ALL PRIVILEGES ON DATABASE dockhand TO psqlUser;

-- Read-Only Benutzer
CREATE USER pg_readonly WITH
    PASSWORD    'DB-read0nly!'
    NOSUPERUSER NOCREATEDB NOCREATEROLE LOGIN;

GRANT ALL PRIVILEGES ON DATABASE DevDB TO pg_readonly;
GRANT ALL PRIVILEGES ON DATABASE BlinkoDB TO pg_readonly;
GRANT ALL PRIVILEGES ON DATABASE DockhandDB TO pg_readonly;
GRANT ALL PRIVILEGES ON DATABASE EtherpadDB TO pg_readonly;
GRANT ALL PRIVILEGES ON DATABASE HedgeDocDB TO pg_readonly;
GRANT ALL PRIVILEGES ON DATABASE PlankanbanDB TO pg_readonly;
GRANT ALL PRIVILEGES ON DATABASE dockhand TO pg_readonly;
EOF
  # Get the file size by using function from wsl2-lib.sh
  # Check if the size is 0 byte
  if [ $(GetFileSize "${PDB_APP_PATH}${PDB_INIT_FILE}") -eq 0 ]; then
    output_fail "🛑 Failed to write new content to ${PDB_APP_PATH}${PDB_INIT_FILE}"
    output_fail "Script $0 exiting ... "
    output_fail "---------------------------------------------------------------------------"
    output_null
    read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
    exit 1
  else
    output_okay "✅ Done."
    output_okay "   Content successfully written to ${PDB_APP_PATH}${PDB_INIT_FILE}"
    output_null
  fi
  
  # Create Compose File using function from wsl2-lib.sh
  CreateNewFile "${DOCKBAY["SQLSTACK"]}/${PDB_COMPOSE}" "Y"
  # Write new content to the compose file
  output_info "ℹ️ Writing content to ${PDB_COMPOSE}. Please wait ..."
cat << EOF > "${DOCKBAY["SQLSTACK"]}/${PDB_COMPOSE}"
# ═══════════════════════════════════════════════════════════════
# /opt/docker/dbhost/docker-compose.yml
# MariaDB + PostgreSQL im gemeinsamen db-cluster Netzwerk
# ═══════════════════════════════════════════════════════════════

services:

  # ─────────────────────────────────────────────────────────────
  # PostgreSQL 16.3
  # ─────────────────────────────────────────────────────────────
  ${PDB_APP_SERVICE}:
    image: postgres:16.3
    container_name: ${PDB_APP_NAME}
    restart: unless-stopped

    environment:
      POSTGRES_USER:          \${POSTGRES_USER}
      POSTGRES_PASSWORD:      \${POSTGRES_PASSWORD}
      POSTGRES_DB:            \${POSTGRES_DB}
      POSTGRES_INITDB_ARGS:   "--encoding=UTF8 --locale=en_US.utf8"
      TZ:                     ${TZ}
      PGTZ:                   ${TZ}

    volumes:
      - ./postgresql/data:/var/lib/postgresql/data
      - ./postgresql/config/postgresql.conf:/etc/postgresql/postgresql.conf:ro
      - ./postgresql/config/pg_hba.conf:/etc/postgresql/pg_hba.conf:ro
      - ./postgresql/init:/docker-entrypoint-initdb.d:ro

    expose:
      - "${PDB_APP_PORT}"
    ports:
      - "127.0.0.1:${PDB_APP_PORT}:${PDB_APP_PORT}"   # ← Aktivieren für Host-Zugriff

    command: >
      postgres
        -c config_file=/etc/postgresql/postgresql.conf
        -c hba_file=/etc/postgresql/pg_hba.conf

    networks:
      db-cluster:
        ipv4_address: ${PDB_SQL_IP}

    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U \${POSTGRES_USER} -d \${POSTGRES_DB}"]
      interval: 15s
      timeout: 5s
      retries: 5
      start_period: 30s

    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 128M

    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

# ═══════════════════════════════════════════════════════════════
# NETZWERK: db-cluster
# attachable: true → andere Compose-Projekte können sich verbinden
# ═══════════════════════════════════════════════════════════════
networks:
  db-cluster:
    external: true
EOF
  # Get the file size by using function from wsl2-lib.sh
  # Check if the size is 0 byte
  if [ $(GetFileSize "${DOCKBAY["SQLSTACK"]}/${PDB_COMPOSE}") -eq 0 ]; then
    output_fail "🛑 Failed to write new content to ${PDB_COMPOSE}"
    output_fail "Script $0 exiting ... "
    output_fail "---------------------------------------------------------------------------"
    output_null
    read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
    exit 1
  else
    output_okay "✅ Done."
    output_okay "   Content successfully written to ${PDB_COMPOSE}"
    output_null
  fi
  
  # Running RestartDockerDaemon from wsl2-lib.sh
  RestartDockerDaemon
  
  output_info "ℹ️ Trying to start Docker Container:  ${PDB_APP_NAME}"
  docker compose -f "${DOCKBAY["SQLSTACK"]}/${PDB_COMPOSE}" up -d
  # Check if the Container could be created and is running
  if [ "$(CheckContainer "${PDB_APP_NAME}")" = "ok" ]; then
    # update the json file
    jq '.setup.psqldbhost = false' $SETUPCFGJSON > $SETUPTMPJSON && mv $SETUPTMPJSON $SETUPCFGJSON
    # update global array
    new_packages=()
    for p in "${DBCLUSTER_PKG[@]}"; do
        if [[ "$p" != "$pkg" ]]; then
            new_packages+=("$p")
        fi
    done
    DBCLUSTER_PKG=("${new_packages[@]}")

    if [ "$(ContainerStatus "${PDB_APP_NAME}")" = "ok" ]; then
      output_okay "✅ Done."
      output_okay "   ${PDB_APP_NAME} successfully created and started"
      output_null
    else
      output_fail "🛑 Failed to start Docker Container for:  ${PDB_APP_NAME}"
      output_fail "The Container was created but could not be started!"
      output_fail "Please start the Container manually!"
      output_null
    fi
  else
    output_fail "🛑 Failed to create Docker Container for:  ${PDB_APP_NAME}"
    output_fail "Script $0 exiting ... "
    output_fail "---------------------------------------------------------------------------"
    output_null
    read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
    exit 1
  fi
fi



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# INSTALLATION OF:  MONGO-DB
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


if [ "$checkmongodb" = "true" ]; then
  output_info "ℹ️ Starting with Setup & Configuration of ${MONGO_APP_NAME} ... "
  output_null
  output_info "ℹ️ Creating Folder Structure ..."
  output_null

  # Create directory structure
  CreateNewPath "${MONGO_APP_PATH}" 775 1000
  for foldername in "${MONGO_SUBFOLDERS[@]}"; do
    CreateNewPath "${MONGO_APP_PATH}/${foldername}" 775 1000
  done
  output_okay "✅ Done."

  # Running SetFolderPermission from wsl2-lib.sh
  SetFolderPermission 777 1000 "${DOCKBAY["SQLSTACK"]}"

  # ======================================================================
  # CREATE USER LOGIN CREDENTIALS (ONLY IF PREVIOUSLY CONFIGURED!)
  # ======================================================================
  if [ "DEFAULT_LOGIN_CREDENTIALS" = "FALSE" ]; then
    output_text "Please create a password for the root-account of MariaDB and hit <enter>"
    MDB_ROOT="$(GetPassword "Enter Password for Root Account (min. 6 chars):")"
    output_okay "✅ Done."
    output_text "Please create default user account for MariaDB and hit <enter>"
    MDB_USER="$(GetUsername "Enter the Username (min. 4 chars):")"
    MDB_PASS="$(GetPassword "Enter the Password (min. 6 chars):")"
    output_okay "✅ Done."
  elif [ "DEFAULT_LOGIN_CREDENTIALS" = "TRUE" ]; then
    output_code "${RED_BOLD}Using default account configurations for MariaDB (based on user input) !!${NC}"
  fi

  # Create Compose File using function from wsl2-lib.sh
  CreateNewFile "${DOCKBAY["SQLSTACK"]}/${MONGO_COMPOSE}" "Y"
  # Write new content to the compose file
  output_info "ℹ️ Writing content to ${MONGO_COMPOSE}. Please wait ..."
cat << EOF > "${DOCKBAY["SQLSTACK"]}/${MONGO_COMPOSE}"
services:
  ${MONGO_APP_SERVICE}:
    image: mongodb/mongodb-community-server:latest
    container_name: ${MONGO_APP_NAME}
    restart: unless-stopped

    ports:
      - "${MONGO_APP_PORT}:${MONGO_APP_PORT}"
    networks:
      db-cluster:
        ipv4_address: ${MONGO_SQL_IP}
    
    environment:
      MONGODB_INITDB_ROOT_USERNAME: ${MONGO_USER}
      MONGODB_INITDB_ROOT_PASSWORD: ${MONGO_PASS}
    
    volumes:
      - ${MONGO_APP_PATH}/dbdata:/data/db
      - ${MONGO_APP_PATH}/config:/data/configdb

networks:
  db-cluster:
    external: true
EOF
  # Get the file size by using function from wsl2-lib.sh
  # Check if the size is 0 byte
  if [ $(GetFileSize "${DOCKBAY["SQLSTACK"]}/${MONGO_COMPOSE}") -eq 0 ]; then
    output_fail "🛑 Failed to write new content to ${MONGO_COMPOSE}"
    output_fail "Script $0 exiting ... "
    output_fail "---------------------------------------------------------------------------"
    output_null
    read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
    exit 1
  else
    output_okay "✅ Done."
    output_okay "   Content successfully written to ${MONGO_COMPOSE}"
    output_null
  fi
  
  # Running RestartDockerDaemon from wsl2-lib.sh
  RestartDockerDaemon
  
  output_info "ℹ️ Trying to start Docker Container:  ${MONGO_APP_NAME}"
  docker compose -f "${DOCKBAY["SQLSTACK"]}/${MONGO_COMPOSE}" up -d
  # Check if the Container could be created and is running
  if [ "$(CheckContainer "${MONGO_APP_NAME}")" = "ok" ]; then
    # update the json file
    jq '.setup.mongodbhost = false' $SETUPCFGJSON > $SETUPTMPJSON && mv $SETUPTMPJSON $SETUPCFGJSON
    # update global array
    new_packages=()
    for p in "${DBCLUSTER_PKG[@]}"; do
        if [[ "$p" != "$pkg" ]]; then
            new_packages+=("$p")
        fi
    done
    DBCLUSTER_PKG=("${new_packages[@]}")

    if [ "$(ContainerStatus "${MONGO_APP_NAME}")" = "ok" ]; then
      output_okay "✅ Done."
      output_okay "   ${MONGO_APP_NAME} successfully created and started"
      output_null
    else
      output_fail "🛑 Failed to start Docker Container for:  ${MONGO_APP_NAME}"
      output_fail "The Container was created but could not be started!"
      output_fail "Please start the Container manually!"
      output_null
    fi
  else
    output_fail "🛑 Failed to create Docker Container for:  ${MONGO_APP_NAME}"
    output_fail "Script $0 exiting ... "
    output_fail "---------------------------------------------------------------------------"
    output_null
    read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
    exit 1
  fi
fi



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# INSTALLATION OF:  DBGATE
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


if [ "$checkdbgate" = "true" ]; then
  output_info "ℹ️ Starting with Setup & Configuration of ${DBGATE_APP_NAME} ... "
  output_null
  output_info "ℹ️ Creating Folder Structure ..."
  output_null

  # Create directory structure
  CreateNewPath "${DBGATE_APP_PATH}" 775 1000
  output_okay "✅ Done."

  # Running SetFolderPermission from wsl2-lib.sh
  SetFolderPermission 777 1000 "${DOCKBAY["SQLSTACK"]}"

  # ======================================================================
  # CREATE USER LOGIN CREDENTIALS (ONLY IF PREVIOUSLY CONFIGURED!)
  # ======================================================================
  if [ "DEFAULT_LOGIN_CREDENTIALS" = "FALSE" ]; then
    output_text "Please create a password for the root-account of MariaDB and hit <enter>"
    MDB_ROOT="$(GetPassword "Enter Password for Root Account (min. 6 chars):")"
    output_okay "✅ Done."
    output_text "Please create default user account for MariaDB and hit <enter>"
    MDB_USER="$(GetUsername "Enter the Username (min. 4 chars):")"
    MDB_PASS="$(GetPassword "Enter the Password (min. 6 chars):")"
    output_okay "✅ Done."
  elif [ "DEFAULT_LOGIN_CREDENTIALS" = "TRUE" ]; then
    output_code "${RED_BOLD}Using default account configurations for MariaDB (based on user input) !!${NC}"
  fi

  # Create .env File using function from wsl2-lib.sh
  CreateNewFile "${DBGATE_ENV}" "Y"
  # Write new content to the .env file
  output_info "ℹ️ Writing content to ${DBGATE_ENV}. Please wait ..."
cat << EOF > $DBGATE_ENV
# ─────────────────────────────────────────
#  DbGate – Umgebungsvariablen
# ─────────────────────────────────────────
APP_IP=${DBGATE_APP_IP}
SQL_IP=${DBGATE_SQL_IP}
# Host-Port, auf dem DbGate erreichbar sein soll
APP_PORT=${DBGATE_APP_PORT}
TCP_PORT=${DBGATE_TCP_PORT}
DBGUSER=${DBGATE_USER}
DBGPASS=${DBGATE_PASS}
# ── MariaDB Verbindung ───────────────────
# Container-Name oder IP deines MariaDB-Containers
MARIADB_HOST=${MDB_APP_NAME}
MARIADB_PORT=${MDB_APP_PORT}
MARIADB_USER=root
MARIADB_PASSWORD=${MDB_ROOT}
MARIADB_LABEL=MariaDB Host

# ── PostgreSQL Verbindung ────────────────
# Container-Name oder IP deines PostgreSQL-Containers
POSTGRES_HOST=${PDB_APP_NAME}
POSTGRES_PORT=${PDB_APP_PORT}
POSTGRES_USER=${PDB_USER}
POSTGRES_PASSWORD=${PDB_PASS}
POSTGRES_LABEL=PostgreSQL Host

# ── MongoDB Verbindung ───────────────────
# Container-Name oder IP deines PostgreSQL-Containers
MONGODB_HOST=${MONGO_APP_NAME}
MONGODB_PORT=${MONGO_APP_PORT}
MONGODB_USER=${MONGO_USER}
MONGODB_PASSWORD=${MONGO_PASS}
MONGODB_LABEL=MongoDB Host
EOF
  # Get the file size by using function from wsl2-lib.sh
  # Check if the size is 0 byte
  if [ $(GetFileSize "${DBGATE_ENV}") -eq 0 ]; then
    output_fail "🛑 Failed to write new content to ${DBGATE_ENV}"
    output_fail "Script $0 exiting ... "
    output_fail "---------------------------------------------------------------------------"
    output_null
    read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
    exit 1
  else
    output_okay "✅ Done."
    output_okay "   Content successfully written to ${DBGATE_ENV}"
    output_null
  fi

  # Creating new Docker Volume using function from wsl2-lib.sh
  CreateNewDockerVolume $DBGATE_DATAVOLUME $DBGATE_APP_NAME

  # Create Compose File using function from wsl2-lib.sh
  CreateNewFile "${DBGATE_APP_PATH}/${DBGATE_COMPOSE}" "Y"
  # Write new content to the compose file
  output_info "ℹ️ Writing content to ${DBGATE_COMPOSE}. Please wait ..."
cat << EOF > "${DBGATE_APP_PATH}/${DBGATE_COMPOSE}"
# -----------------------------------------------------------------------------
#  DbGate – Docker Compose
#  Netzwerke: db-cluster (Datenbankzugriff) + apphost (Web-Zugriff)
# -----------------------------------------------------------------------------

services:
  ${DBGATE_APP_NAME}:
    image: dbgate/dbgate:latest
    container_name: ${DBGATE_APP_NAME}
    restart: unless-stopped

    ports:
      - "\${APP_PORT}:\${TCP_PORT}"

    volumes:
      # Persistenz für gespeicherte Skripte, Verbindungen (manuell hinzugefügte),
      # Archive und Einstellungen
      - DBGateData:/root/.dbgate

    environment:
      LANGUAGE: de
      WEB_ROOT: /dbadmin
      LOGIN:    \${DBGUSER}
      PASSWORD: \${DBGPASS}
      # -- Vordefinierte Verbindungen ------------------------------------------
      # Kommagetrennte Liste der Verbindungs-IDs (frei wählbare Bezeichner)
      CONNECTIONS: "mariadb_connex,postgres_connex,mongodb_connex"

      # -- MariaDB / MySQL Verbindung ------------------------------------------
      LABEL_mariadb_connex:    "\${MARIADB_LABEL}"
      SERVER_mariadb_connex:   "\${MARIADB_HOST}"
      PORT_mariadb_connex:     "\${MARIADB_PORT}"
      USER_mariadb_connex:     "\${MARIADB_USER}"
      PASSWORD_mariadb_connex: "\${MARIADB_PASSWORD}"
      # MariaDB nutzt das mysql-Plugin (vollständig kompatibel)
      ENGINE_mariadb_connex:   "mysql@dbgate-plugin-mysql"

      # -- PostgreSQL Verbindung -----------------------------------------------
      LABEL_postgres_connex:    "\${POSTGRES_LABEL}"
      SERVER_postgres_connex:   "\${POSTGRES_HOST}"
      PORT_postgres_connex:     "\${POSTGRES_PORT}"
      USER_postgres_connex:     "\${POSTGRES_USER}"
      PASSWORD_postgres_connex: "\${POSTGRES_PASSWORD}"
      ENGINE_postgres_connex:   "postgres@dbgate-plugin-postgres"

      # -- MongoDB Verbindung --------------------------------------------------
      LABEL_mongodb_connex:    "\${MONGODB_LABEL}"
      SERVER_mongodb_connex:   "\${MONGODB_HOST}"
      PORT_mongodb_connex:     "\${MONGODB_PORT}"
      USER_mongodb_connex:     "\${MONGODB_USER}"
      PASSWORD_mongodb_connex: "\${MONGODB_PASSWORD}"
      # MariaDB nutzt das mysql-Plugin (vollständig kompatibel)
      ENGINE_mongodb_connex:   "mongo@dbgate-plugin-mongo"


    networks:
      system-core:
        ipv4_address: \${APP_IP}
      db-cluster:
        ipv4_address: \${SQL_IP}

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
  if [ $(GetFileSize "${DBGATE_APP_PATH}/${DBGATE_COMPOSE}") -eq 0 ]; then
    output_fail "🛑 Failed to write new content to ${DBGATE_COMPOSE}"
    output_fail "Script $0 exiting ... "
    output_fail "---------------------------------------------------------------------------"
    output_null
    read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
    exit 1
  else
    output_okay "✅ Done."
    output_okay "   Content successfully written to ${DBGATE_COMPOSE}"
    output_null
  fi
  
  # Running RestartDockerDaemon from wsl2-lib.sh
  RestartDockerDaemon
  
  output_info "ℹ️ Trying to start Docker Container:  ${DBGATE_APP_NAME}"
  docker compose -f "${DBGATE_APP_PATH}/${DBGATE_COMPOSE}" up -d
  # Check if the Container could be created and is running
  if [ "$(CheckContainer "${DBGATE_APP_NAME}")" = "ok" ]; then
    # update the json file
    jq '.app.DBGate = false' $SETUPCFGJSON > $SETUPTMPJSON && mv $SETUPTMPJSON $SETUPCFGJSON
    # update global array
    new_packages=()
    for p in "${DBCLUSTER_PKG[@]}"; do
        if [[ "$p" != "$pkg" ]]; then
            new_packages+=("$p")
        fi
    done
    DBCLUSTER_PKG=("${new_packages[@]}")

    if [ "$(ContainerStatus "${DBGATE_APP_NAME}")" = "ok" ]; then
      output_okay "✅ Done."
      output_okay "   ${DBGATE_APP_NAME} successfully created and started"
      output_null
    else
      output_fail "🛑 Failed to start Docker Container for:  ${DBGATE_APP_NAME}"
      output_fail "The Container was created but could not be started!"
      output_fail "Please start the Container manually!"
      output_null
    fi
  else
    output_fail "🛑 Failed to create Docker Container for:  ${DBGATE_APP_NAME}"
    output_fail "Script $0 exiting ... "
    output_fail "---------------------------------------------------------------------------"
    output_null
    read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
    exit 1
  fi
fi




# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# MAIN SCRIPT FINISHED - OPTIONALLY RUN 'DOCKER COMPOSE UP -D' RIGHT NOW
clear
output_info "$0 finished."
output_null
output_info "Installation of ${APP_FULL_NAME} finished."
output_null
output_text "Container Name: ${MDB_APP_NAME}"
output_text "Current Status → $(docker inspect --format '{{.State.Status}}' $MDB_APP_NAME)"
output_text "$(docker ps -a --filter "name=${MDB_APP_NAME}" --format "{{.Status}}")"
output_text "Container ID:   $(docker ps -a --filter "name=${MDB_APP_NAME}" --format "{{.ID}}")"
output_text "Used Image:     $(docker ps -a --filter "name=${MDB_APP_NAME}" --format "{{.Image}}")"
output_null
output_text "Container Name: ${PDB_APP_NAME}"
output_text "Current Status → $(docker inspect --format '{{.State.Status}}' $PDB_APP_NAME)"
output_text "Container ID:   $(docker ps -a --filter "name=${PDB_APP_NAME}" --format "{{.ID}}")"
output_text "Used Image:     $(docker ps -a --filter "name=${PDB_APP_NAME}" --format "{{.Image}}")"
output_null
output_text "Container Name: ${MONGO_APP_NAME}"
output_text "Current Status → $(docker inspect --format '{{.State.Status}}' $MONGO_APP_NAME)"
output_text "$(docker ps -a --filter "name=${MONGO_APP_NAME}" --format "{{.Status}}")"
output_text "Container ID:   $(docker ps -a --filter "name=${MONGO_APP_NAME}" --format "{{.ID}}")"
output_text "Used Image:     $(docker ps -a --filter "name=${MONGO_APP_NAME}" --format "{{.Image}}")"
output_null
output_text "Container Name: ${DBGATE_APP_NAME}"
output_text "Current Status → $(docker inspect --format '{{.State.Status}}' $DBGATE_APP_NAME)"
output_text "$(docker ps -a --filter "name=${DBGATE_APP_NAME}" --format "{{.Status}}")"
output_text "Container ID:   $(docker ps -a --filter "name=${DBGATE_APP_NAME}" --format "{{.ID}}")"
output_text "Used Image:     $(docker ps -a --filter "name=${DBGATE_APP_NAME}" --format "{{.Image}}")"
output_null
output_text "Enjoy using your ${APP_FULL_NAME} installation :)"
output_null
output_text "$0 is exiting now ..."
output_null
read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to return to the Main Screen ...\033[0m'
echo ""
exit 0

# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# DOCUMENTATION AND USAGE INSTRUCTIONS


: <<'INFO'
# TO BE DOCUMENTED ...
INFO
