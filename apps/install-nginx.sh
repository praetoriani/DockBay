#!/usr/bin/env bash
cat << 'SCRIPT-INFO' > /dev/null
This Shell Script will install & configure the following App: Nginx Proxy Manager
Place this script in /usr/local/bin make it executable and run it with sudo privileges
URL: https://docs.planka.cloud/docs/installation/docker/production-version
⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
TEST RESULTS:  SUCCESSFULLY TESTED ON WSL2/DEBIAN ON 04.06.2026
⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
Script Name:   install-nginx.sh
Last Update:   14.06.2026
Written by:    Praetoriani
Website:       https://github.com/praetoriani
⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
SCRIPT-INFO

# Load the WSL2 Library (important for this script)
source ../main/dockbay.lib.sh

# START WITH A CLEAN CONSOLE
clear

# Get the IP-Address of the WSL2/Debian Instance
HOST_IP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# THE FOLOWING SECTION IS A SET OF SCRIPT VARIABLES WHICH ARE USED TO CONFIGURE THE INSTALLATION OF THE DOCKER CONTAINER
CURRENT_USER=$(whoami)                              # This is the current user (who executed this script)
#------------------------------------------------------------------------------------------------------------------------------------------------------
# MAIN DOCKER CONFIGURATION
DOCKERDIR="/opt/docker"                             # Absolute path to the root directory of the docker stacks
APP_FULL_NAME="Nginx Proxy Manager"                 # Full name of the App that will be installed (only used for console output)
APP_NAME="nginx-pm"                                 # The folder name of the App (do not use spaces! only use lowercase and - or _ )
APP_SERVICE="NginxProxy"                            # The Name of the Service (Container Name) for the Compose File
APP_PATH="${DOCKERDIR}/sysapp/${APP_NAME}"          # Absolute path to the Installation Directory
APP_COMPOSE="${APP_NAME}-compose.yml"               # The name of the Docker Compose file (do not change this!)
#------------------------------------------------------------------------------------------------------------------------------------------------------
# ADDITIONAL CONFIGURATION
APP_ENV_FILE=".env"                                 # The name of the .env-file for the Docker Compose File
DB_PASSWORD="sql-pass.key"                          # Only for Nginx! → Stores the password to access the database
USER_PASSWD="user-pass.key"                         # Only for Nginx! → Stores the password for the admin user
#------------------------------------------------------------------------------------------------------------------------------------------------------
# NETWORK CONFIGURATION
APP_PORT="80:80"                                    # This is the Port Number which will be exposed for public access
ADM_PORT="81:81"                                    # This is the Port Number the Docker Container uses internally
SSL_PORT="443:443"                                  # This is the Port Number the Docker Container uses internally
APP_IP="172.22.1.1"                                 # The (fixed) IP for the Docker Container (Gateway must already exist!)
NPM_IP="172.50.1.1"                                 # The (fixed) IP for the nginx-proxy Network
SQL_IP="172.30.1.1"                                 # The (fixed) IP for the db-cluster Network
APP_DB_NAME="NginxProxyDB"                          # This is the Name of the Database which is used by the Container
#------------------------------------------------------------------------------------------------------------------------------------------------------
# VOLUME & LOCAL MOUNT POINTS
DATA_VOLUME="NginxProxyData"                        # Name of the Docker Volume -> Only needed if app needs a Docker Volume!
MOUNTPOINT1="${APP_PATH}/data"                      # Optional: Path to a local mount point for persistent data
MOUNTPOINT2="${APP_PATH}/letsencrypt"               # Optional: Path to a local mount point for persistent data
MOUNTPOINT3="${APP_PATH}/mkcert"                    # Optional: Path to a local mount point for persistent data


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
output_note "Important Information:"
output_note "${APP_FULL_NAME} is connected to the MariaDB Database"
output_note "inside the DB Cluster. ${APP_FULL_NAME} needs the following"
output_note "Database inside your MariaDB Database Host: '${APP_DB_NAME}'"
output_note ""
output_note "Please make sure that this Database exists, before running"
output_note "the container for the first time after installation!"
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
CreateLocalMountPoint $MOUNTPOINT2 775 1000
CreateLocalMountPoint $MOUNTPOINT3 775 1000

# Create .env File using function from wsl2-lib.sh
CreateNewFile "${APP_PATH}/${APP_ENV_FILE}" "Y"

# Write new content to the .env file
output_info "ℹ️ Writing content to ${APP_ENV_FILE}. Please wait ..."
cat << EOF > $APP_PATH/$APP_ENV_FILE
# ----- Main Container Settings -------------------------
APP_SERVICE=${APP_SERVICE}
APP_IP=${APP_IP}
NPM_IP=${NPM_IP}
SQL_IP=${SQL_IP}
TIMEZONE="Europe/Berlin"
DISABLE_IPV6='true'
# ----- Security  Settings ------------------------------
INITIAL_ADMIN_EMAIL=admin@nginx.local
USER_PASS_FILE=${APP_PATH}/${USER_PASSWD}
DB_SECRET_FILE=${APP_PATH}/${DB_PASSWORD}
# ----- Local Mount Point Settings ----------------------
MOUNTPOINT1=${MOUNTPOINT1}
MOUNTPOINT2=${MOUNTPOINT2}
MOUNTPOINT3=${MOUNTPOINT3}
# ----- MariaDB Connex Settings -------------------------
DB_MYSQL_HOST: "MariaDB-Host"
DB_MYSQL_PORT: 3306
DB_MYSQL_USER: "root"
DB_MYSQL_NAME: "${APP_DB_NAME}"
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
  output_okay "   Content successfully written to ${APP_ENV_FILE}"
  output_null
fi

# Create Password File using function from wsl2-lib.sh
CreateNewFile "${APP_PATH}/${DB_PASSWORD}" "Y"

# Write new content to the Password file
output_info "ℹ️ Writing content to ${DB_PASSWORD}. Please wait ..."
cat << EOF > $APP_PATH/$DB_PASSWORD
Xg!8vQ-S9hYeV5Xe
EOF
# Get the file size by using function from wsl2-lib.sh
# Check if the size is 0 byte
if [ $(GetFileSize "${APP_PATH}/${DB_PASSWORD}") -eq 0 ]; then
  output_fail "🛑 Failed to write new content to ${APP_PATH}/${DB_PASSWORD}"
  output_fail "Script $0 exiting ... "
  output_fail "---------------------------------------------------------------------------"
  output_null
  read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
  exit 1
else
  output_okay "✅ Done."
  output_okay "   Content successfully written to ${DB_PASSWORD}"
  output_null
fi

# Create Password File (for admin user) using function from wsl2-lib.sh
CreateNewFile "${APP_PATH}/${USER_PASSWD}" "Y"

# Write new content to the Password file
output_info "ℹ️ Writing content to ${USER_PASSWD}. Please wait ..."
cat << EOF > $APP_PATH/$USER_PASSWD
Xg!8vQ-S9hYeV5Xe
EOF
# Get the file size by using function from wsl2-lib.sh
# Check if the size is 0 byte
if [ $(GetFileSize "${APP_PATH}/${USER_PASSWD}") -eq 0 ]; then
  output_fail "🛑 Failed to write new content to ${APP_PATH}/${USER_PASSWD}"
  output_fail "Script $0 exiting ... "
  output_fail "---------------------------------------------------------------------------"
  output_null
  read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
  exit 1
else
  output_okay "✅ Done."
  output_okay "   Content successfully written to ${USER_PASSWD}"
  output_null
fi

# Create Compose File using function from wsl2-lib.sh
CreateNewFile "${APP_PATH}/${APP_COMPOSE}" "Y"

# Write new content to the compose file
output_info "ℹ️ Writing content to ${APP_COMPOSE}. Please wait ..."
cat << 'EOF' > $APP_PATH/$APP_COMPOSE
# ----- SECRETS CONFIGURATION -------------------------
secrets:
  # Secrets are single-line text files where the sole content is the secret
  # Paths in this example assume that secrets are kept in local folder called ".secrets"
  # You can set any environment variable from a file by appending
  # __FILE (double-underscore FILE) to the environmental variable name.
  MYSQL_PWD:
    file: ${DB_SECRET_FILE}
  LOGIN_PWD:
    file: ${USER_PASS_FILE}

# ----- NETWORK CONFIGURATION -------------------------
networks:
  db-cluster:
    external: true
    name: db-cluster
  nginx-proxy:
    external: true
    name: nginx-proxy

# ----- SERVICE CONFIGURATION -------------------------
services:
  NginxProxy:
    image: 'jc21/nginx-proxy-manager:latest'
    container_name: ${APP_SERVICE}
    restart: unless-stopped

    # Refer to the previously defined secrets
    secrets:
      - MYSQL_PWD
      - LOGIN_PWD

    ports:
      - '80:80'     # HTTP
      - '443:443'   # HTTPS
      - '81:81'     # NPM Admin-UI (nur lokal!)

    networks:
      db-cluster:
        ipv4_address: ${SQL_IP}
      nginx-proxy:
        ipv4_address: ${NPM_IP}

    environment:
      # These are the settings to access the admin board
      INITIAL_ADMIN_EMAIL: ${INITIAL_ADMIN_EMAIL}
      INITIAL_ADMIN_PASSWORD__FILE: /run/secrets/LOGIN_PWD
      # These are the settings to access your db
      DB_MYSQL_HOST: ${DB_MYSQL_HOST}
      DB_MYSQL_PORT: ${DB_MYSQL_PORT}
      DB_MYSQL_USER: ${DB_MYSQL_USER}
      DB_MYSQL_PASSWORD__FILE: /run/secrets/MYSQL_PWD
      DB_MYSQL_NAME: ${DB_MYSQL_NAME}
      TZ: ${TIMEZONE}
      DISABLE_IPV6: ${DISABLE_IPV6}
      IP_RANGES_FETCH_ENABLED: 'false'  # No Internet-Acces on Cloudflare-IPs

    volumes:
      - ${MOUNTPOINT1}:/data
      - ${MOUNTPOINT2}:/etc/letsencrypt
      - ${MOUNTPOINT3}:/certs

    healthcheck:
      test: ["CMD", "/usr/bin/check-health"]
      interval: 10s
      timeout: 3s

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
output_note "💡 Please Note:"
output_note "Use the following credentials to login:"
output_note "User:  admin@nginx.local"
output_note "Pass:  R00tP4ssw0rd!"
output_null
output_warn "⚠️ Change the Default Settings after first login !!"
output_null
output_info "${APP_FULL_NAME} can be accessed via following URL:"
output_null
output_text "http://localhost:${APP_PORT}"
output_text "or"
output_text "http://${HOST_IP}:${APP_PORT}"
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
