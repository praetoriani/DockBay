#!/usr/bin/env bash
cat << 'SCRIPT-INFO' > /dev/null
This Shell Script will install & configure the following App: Planka
Place this script in /usr/local/bin make it executable and run it with sudo privileges
URL: https://docs.planka.cloud/docs/installation/docker/production-version
⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
TEST RESULTS:  SUCCESSFULLY TESTED ON WSL2/DEBIAN ON 06.06.2026
⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
Script Name:   install-planka.sh
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
APP_FULL_NAME="Planka"                              # Full name of the App that will be installed (only used for console output)
APP_NAME="planka"                                   # The folder name of the App (do not use spaces! only use lowercase and - or _ )
APP_SERVICE="Planka"                                # The Name of the Service (Container Name) for the Compose File
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
APP_PWDFILE="account.pwd"                            # Only for Planka! → Stores the password for the default account
APP_SECFILE="app-sec.key"                            # Only for Planka! → Stores the random secret key
DB_PASSWORD="db-pass.key"                            # Only for Planka! → Stores the password to access the database
#------------------------------------------------------------------------------------------------------------------------------------------------------
# NETWORK CONFIGURATION
APP_PORT="5000"                                     # This is the Port Number which will be exposed for public access
TCP_PORT="1337"                                     # This is the Port Number the Docker Container uses internally
APP_IP="172.24.0.8"                                 # The (fixed) IP for the Docker Container (Gateway must already exist!)
SQL_IP="172.30.0.6"                                 # The (fixed) IP for the db-cluster Network
APP_DB_NAME="PlankanbanDB"                          # This is the Name of the Database which is used by the Container
APP_DOMAIN="planka.localhost"                       # This is the Domain/URL Traefik is going to use to expose this app
#------------------------------------------------------------------------------------------------------------------------------------------------------
# VOLUME & LOCAL MOUNT POINTS
DATA_VOLUME="PlankaData"                            # Name of the Docker Volume -> Only needed if app needs a Docker Volume!


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

# Create Password File using function from wsl2-lib.sh
CreateNewFile "${APP_PATH}/${APP_PWDFILE}" "Y"

# Write new content to the Password file
output_info "ℹ️ Writing content to ${APP_PWDFILE}. Please wait ..."
cat << EOF > $APP_PATH/$APP_PWDFILE
R00t4dm!n
EOF
# Get the file size by using function from wsl2-lib.sh
# Check if the size is 0 byte
if [ $(GetFileSize "${APP_PATH}/${APP_PWDFILE}") -eq 0 ]; then
  output_fail "🛑 Failed to write new content to ${APP_PATH}/${APP_PWDFILE}"
  output_fail "Script $0 exiting ... "
  output_fail "---------------------------------------------------------------------------"
  output_null
  read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
  exit 1
else
  output_okay "✅ Done."
  output_okay "   Content successfully written to ${APP_PWDFILE}"
  output_null
fi

# Create Secret Key File using function from wsl2-lib.sh
CreateNewFile "${APP_PATH}/${APP_SECFILE}" "Y"

# Write new content to the Secret Key file
output_info "ℹ️ Writing content to ${APP_SECFILE}. Please wait ..."
cat << EOF > $APP_PATH/$APP_SECFILE
8f427253b14e6100fd717149118cd70e3e43358d91f5b6d7dad8f08801143910c6e5b6119b95d9be52d8ab374fff87a5eb4bd118d6df26ea63a90b7d849798c2
EOF
# Get the file size by using function from wsl2-lib.sh
# Check if the size is 0 byte
if [ $(GetFileSize "${APP_PATH}/${APP_SECFILE}") -eq 0 ]; then
  output_fail "🛑 Failed to write new content to ${APP_PATH}/${APP_SECFILE}"
  output_fail "Script $0 exiting ... "
  output_fail "---------------------------------------------------------------------------"
  output_null
  read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
  exit 1
else
  output_okay "✅ Done."
  output_okay "   Content successfully written to ${APP_SECFILE}"
  output_null
fi

# Create Secret Key File using function from wsl2-lib.sh
CreateNewFile "${APP_PATH}/${DB_PASSWORD}" "Y"

# Write new content to the Secret Key file
output_info "ℹ️ Writing content to ${DB_PASSWORD}. Please wait ..."
cat << EOF > $APP_PATH/$DB_PASSWORD
P6k%2E5D%219FvCq%23hW%2BT
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

# Creating new Volume using function from wsl2-lib.sh
CreateNewDockerVolume $DATA_VOLUME $APP_NAME

# Create Compose File using function from wsl2-lib.sh
CreateNewFile "${APP_PATH}/${APP_COMPOSE}" "Y"

output_info "ℹ️ Writing content to ${APP_COMPOSE}. Please wait ..."
# Write new content to the compose file
cat << EOF > $APP_PATH/$APP_COMPOSE
services:
  ${APP_SERVICE}:
    image: ghcr.io/plankanban/planka:latest
    container_name: ${APP_SERVICE}
    restart: on-failure

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

    volumes:
      - ${DATA_VOLUME}:/app/data
      # - ./terms:/app/terms/custom
    # Optionally override this to your user/group
    # user: 1000:1000
    # tmpfs:
    #   - /app/.tmp:mode=770,uid=1000,gid=1000
    ports:
      - ${APP_PORT}:${TCP_PORT}
    networks:
      apphost:
        ipv4_address: ${APP_IP}
      db-cluster:
        ipv4_address: ${SQL_IP}

    environment:
      - BASE_URL=http://localhost:${APP_PORT}
      - DATABASE_URL=postgresql://postgres_admin:P6k%2E5D%219FvCq%23hW%2BTk@postgresql:5432/${APP_DB_NAME}

      - SECRET_KEY=8f427253b14e6100fd717149118cd70e3e43358d91f5b6d7dad8f08801143910c6e5b6119b95d9be52d8ab374fff87a5eb4bd118d6df26ea63a90b7d849798c2

      - LOG_LEVEL=warn

      # - TRUST_PROXY=true
      # - MAX_UPLOAD_FILE_SIZE=
      # - TOKEN_EXPIRES_IN=365 # In days

      # - STORAGE_LIMIT=
      # - ACTIVE_USERS_LIMIT=

      # The default application language used as a fallback when a user's language is not set.
      # This language is also used for per-board notifications.
      - DEFAULT_LANGUAGE=en-US

      # Do not comment out DEFAULT_ADMIN_EMAIL if you want to prevent this user from being edited/deleted
      - DEFAULT_ADMIN_EMAIL=admin@plankanban.local
      - DEFAULT_ADMIN_PASSWORD=r00t4dmin
      - DEFAULT_ADMIN_NAME=Planka Root
      - DEFAULT_ADMIN_USERNAME=superuser

      # Set to true to show more detailed authentication error messages.
      # It should not be enabled without a rate limiter for security reasons.
      - SHOW_DETAILED_AUTH_ERRORS=false

      # All outgoing HTTP requests (SMTP, webhooks, Apprise notifications, favicon fetching, etc.)
      # will be sent through this proxy if set.
      # If commented out, an internal Squid proxy will be started inside the container,
      # which you can control via OUTGOING_BLOCKED_* and OUTGOING_ALLOWED_* below.
      # - OUTGOING_PROXY=http://proxy:3128

      # Email Notifications (https://nodemailer.com/smtp/)
      # These values override and disable configuration in the UI if set.
      # - SMTP_HOST=
      # - SMTP_PORT=587
      # - SMTP_NAME=
      # - SMTP_SECURE=true
      # - SMTP_TLS_REJECT_UNAUTHORIZED=false
      # - SMTP_USER=
      # - SMTP_PASSWORD=
      # Optionally store in secrets - then SMTP_PASSWORD should not be set
      # - SMTP_PASSWORD__FILE=/run/secrets/smtp_password
      # - SMTP_FROM="Demo Demo" <demo@demo.demo>

      # --------------------------------------------------------------------
      # Outgoing traffic control (internal Squid proxy)
      # --------------------------------------------------------------------

      # These IPs/hostnames will always be blocked (highest priority)
      # - OUTGOING_BLOCKED_IPS=
      # - OUTGOING_BLOCKED_HOSTS=localhost,postgres

      # Only these IPs/hostnames will be reachable
      # - OUTGOING_ALLOWED_IPS=
      # - OUTGOING_ALLOWED_HOSTS=

volumes:
  ${DATA_VOLUME}:
    external: true

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
output_text "📌 Please Note:"
output_text "Use the following credentials to login:"
output_text "User:  superuser"
output_text "Pass:  r00t4dmin"
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
