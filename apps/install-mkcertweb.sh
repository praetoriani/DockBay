#!/usr/bin/env bash
cat << 'SCRIPT-INFO' > /dev/null
This Shell Script will install & configure the following App: mkcert Web UI
Place this script in /usr/local/bin make it executable and run it with sudo privileges
URL: https://github.com/jeffcaldwellca/mkcertWeb/tree/main
⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
TEST RESULTS:  ✓ SUCCESSFULLY TESTED ON WSL2/DEBIAN ON 07.06.2026
⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
Script Name:   install-mkcertweb.sh
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
SetupLocationConfig "sys"

# Get the IP-Address of the WSL2/Debian Instance
HOST_IP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# THE FOLOWING SECTION IS A SET OF SCRIPT VARIABLES WHICH ARE USED TO CONFIGURE THE INSTALLATION OF THE DOCKER CONTAINER
CURRENT_USER=$(whoami)                              # This is the current user (who executed this script)
#------------------------------------------------------------------------------------------------------------------------------------------------------
# MAIN DOCKER CONFIGURATION
DOCKERDIR="/opt/docker"                             # Absolute path to the root directory of the docker stacks
APP_FULL_NAME="mkcert Web UI"                       # Full name of the App that will be installed (only used for console output)
APP_NAME="mkcert"                                   # The folder name of the App (do not use spaces! only use lowercase and - or _ )
APP_SERVICE="mkcertweb"                             # The Name of the Service (Container Name) for the Compose File
APP_PATH="${DOCKERDIR}/sysapp/${APP_NAME}"          # Absolute path to the Installation Directory
APP_COMPOSE="${APP_NAME}-compose.yml"               # The name of the Docker Compose file (do not change this!)
#------------------------------------------------------------------------------------------------------------------------------------------------------
# ADDITIONAL CONFIGURATION
APP_ENV_FILE=".env"                                 # The name of the .env-file for the Docker Compose File
USER_PASS_FILE="user.key"                           # This file stores the password for the admin user
AUTH_HASH_FILE="auth.key"                           # Stores a Hash to secure the password
SESSION_SECRET="session.key"                        # Stores a secret seed for the session management
#------------------------------------------------------------------------------------------------------------------------------------------------------
# NETWORK CONFIGURATION
APP_PORT="3000"                                     # This is the Port Number which will be exposed for public access
TCP_PORT="3000"                                     # This is the Port Number the Docker Container uses internally
APP_PORT_SSL="3443"                                 # This is the Port Number which will be exposed for public access
TCP_PORT_SSL="3443"                                 # This is the Port Number the Docker Container uses internally
SYS_IP="172.22.2.1"                                 # The (fixed) IP for the Docker Container (Gateway must already exist!)
#------------------------------------------------------------------------------------------------------------------------------------------------------
# VOLUME & LOCAL MOUNT POINTS
DATAVOLUME1="mkcert-appdata"                        # Name of the Docker Volume -> Only needed if app needs a Docker Volume!
MOUNTPOINT1="${APP_PATH}/appdata"                   # Optional: Path to a local mount point for persistent data
MOUNTPOINT2="${APP_PATH}/certs"                     # Optional: Path to a local mount point for persistent data
MOUNTPOINT3="${APP_PATH}/mkcert-ca"                 # Optional: Path to a local mount point for persistent data


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

# Creating new mountpoints using function from wsl2-lib.sh
CreateLocalMountPoint $MOUNTPOINT1 775 1000
CreateLocalMountPoint $MOUNTPOINT2 775 1000
CreateLocalMountPoint $MOUNTPOINT3 775 1000

# Create Password File using function from wsl2-lib.sh
CreateNewFile "${APP_PATH}/${USER_PASS_FILE}" "Y"

# Write new content to the Password file
output_info "ℹ️ Writing content to ${USER_PASS_FILE}. Please wait ..."
cat << EOF > $APP_PATH/$USER_PASS_FILE
4dm1nP4ssw0rd!
EOF
# Get the file size by using function from wsl2-lib.sh
# Check if the size is 0 byte
if [ $(GetFileSize "${APP_PATH}/${USER_PASS_FILE}") -eq 0 ]; then
  output_fail "🛑 Failed to write new content to ${APP_PATH}/${USER_PASS_FILE}"
  output_fail "Script $0 exiting ... "
  output_fail "---------------------------------------------------------------------------"
  output_null
  read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
  exit 1
else
  output_okay "✅ Done."
  output_okay "   Content successfully written to ${USER_PASS_FILE}"
  output_null
fi

# Create Secret Hash File using function from wsl2-lib.sh
CreateNewFile "${APP_PATH}/${AUTH_HASH_FILE}" "Y"

# Write new content to the Secret Hash file
output_info "ℹ️ Writing content to ${AUTH_HASH_FILE}. Please wait ..."
cat << EOF > $APP_PATH/$AUTH_HASH_FILE
485a8d58394f3ed7fc33935e4f315d842c5bf190851ef4f45bae7ca8f903abcf75f8b176ff6fa6f5c513d2f7b6d5eed4
EOF
# Get the file size by using function from wsl2-lib.sh
# Check if the size is 0 byte
if [ $(GetFileSize "${APP_PATH}/${AUTH_HASH_FILE}") -eq 0 ]; then
  output_fail "🛑 Failed to write new content to ${APP_PATH}/${AUTH_HASH_FILE}"
  output_fail "Script $0 exiting ... "
  output_fail "---------------------------------------------------------------------------"
  output_null
  read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
  exit 1
else
  output_okay "✅ Done."
  output_okay "   Content successfully written to ${AUTH_HASH_FILE}"
  output_null
fi

# Create Secret Hash File using function from wsl2-lib.sh
CreateNewFile "${APP_PATH}/${SESSION_SECRET}" "Y"

# Write new content to the Secret Hash file
output_info "ℹ️ Writing content to ${SESSION_SECRET}. Please wait ..."
cat << EOF > $APP_PATH/$SESSION_SECRET
b0bcb02bc2b9d425676e1ac059b80be8a41de7ee94d408c75008ea4e29c73f7aa6b6177ede1d9def9fcadb4b82fdf4b2
EOF
# Get the file size by using function from wsl2-lib.sh
# Check if the size is 0 byte
if [ $(GetFileSize "${APP_PATH}/${SESSION_SECRET}") -eq 0 ]; then
  output_fail "🛑 Failed to write new content to ${APP_PATH}/${SESSION_SECRET}"
  output_fail "Script $0 exiting ... "
  output_fail "---------------------------------------------------------------------------"
  output_null
  read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
  exit 1
else
  output_okay "✅ Done."
  output_okay "   Content successfully written to ${SESSION_SECRET}"
  output_null
fi

# Create Compose File using function from wsl2-lib.sh
CreateNewFile "${APP_PATH}/${APP_COMPOSE}" "Y"

# Write new content to the compose file
output_info "ℹ️ Writing content to ${APP_COMPOSE}. Please wait ..."
cat << EOF > $APP_PATH/$APP_COMPOSE

# ----- SECRETS CONFIGURATION -------------------------
#secrets:
#  # Secrets are single-line text files where the sole content is the secret
#  # Paths in this example assume that secrets are kept in local folder called ".secrets"
#  # You can set any environment variable from a file by appending
#  # __FILE (double-underscore FILE) to the environmental variable name.
#  LOGIN_PWD:
#    file: ${USER_PASS_FILE}
#  AUTH_HASH:
#    file: ${AUTH_HASH_FILE}
#  SECRET_SESSION:
#    file: ${SESSION_SECRET}

# ----- VOLUME/STORAGE CONFIGURATION ------------------
#volumes:
#  ${DATAVOLUME1}: # appdata
#    external: true
#    driver: local

# ----- NETWORK CONFIGURATION -------------------------
networks:
  system-core:
    external: true
    name: system-core

# ----- SERVICE CONFIGURATION -------------------------
services:
  ${APP_SERVICE}:
    image: jeffcaldwellca/mkcertweb:latest
    container_name: ${APP_SERVICE}
    restart: unless-stopped

    # Following Section is only important for Traefik Proxy
    labels:
      - "traefik.enable=true"

      # Router for HTTP
      - "traefik.http.routers.${APP_NAME}.rule=Host(\`${APP_DOMAIN}\`)"
      - "traefik.http.routers.${APP_NAME}.entrypoints=WEB"

      # Service → internal Port of the Container
      - "traefik.http.services.${APP_NAME}.loadbalancer.server.port=${TCP_PORT}"

      # Optional: HTTPS
      - "traefik.http.routers.${APP_NAME}-secure.rule=Host(\`${APP_DOMAIN}\`)"
      - "traefik.http.routers.${APP_NAME}-secure.entrypoints=WEBSECURE"
      - "traefik.http.routers.${APP_NAME}-secure.tls=true"

    # Refer to the previously defined secrets
    #secrets:
    #  - LOGIN_PWD
    #  - AUTH_HASH
    #  - SECRET_SESSION

    ports:
      - "${APP_PORT}:${TCP_PORT}"            # HTTP port
      - "${APP_PORT_SSL}:${TCP_PORT_SSL}"    # HTTPS port
    networks:
      system-core:
        ipv4_address: ${SYS_IP}

    environment:
      # Server Configuration
      - PORT=${APP_PORT}
      - HTTPS_PORT=${APP_PORT_SSL}
      - HOST=127.0.0.1
      
      # SSL/HTTPS Configuration
      - ENABLE_HTTPS=false
      - SSL_DOMAIN=localhost
      - FORCE_HTTPS=false
      
      # Application Configuration
      - NODE_ENV=production
      - THEME_MODE=dark
      
      # Authentication Configuration (disabled by default).
      # SECURITY: do NOT set AUTH_PASSWORD or SESSION_SECRET to the placeholder
      # values shown in older versions of this file. If unset, the app will
      # mint an ephemeral SESSION_SECRET on each boot, and (if ENABLE_AUTH=true)
      # generate a random AUTH_PASSWORD that prints to the container logs.
      # Override here, in a .env file, or with docker run -e ....
      - ENABLE_AUTH=true
      - AUTH_USERNAME=admin
      #- AUTH_PASSWORD__FILE: /run/secrets/LOGIN_PWD
      #- AUTH_PASSWORD_HASH__FILE: /run/secrets/AUTH_HASH
      - AUTH_PASSWORD=4dm1nP4ssw0rd!
      # - AUTH_PASSWORD_HASH=<bcrypt hash; takes precedence over AUTH_PASSWORD>
      - SESSION_SECRET=$(openssl rand -hex 48)
      #- SESSION_SECRET__FILE: /run/secrets/SECRET_SESSION
      
      # Rate Limiting Configuration
      - CLI_RATE_LIMIT_WINDOW=900000   # CLI operations window (15 minutes)
      - CLI_RATE_LIMIT_MAX=10          # Max CLI operations per window
      - API_RATE_LIMIT_WINDOW=900000   # API requests window (15 minutes)  
      - API_RATE_LIMIT_MAX=100         # Max API requests per window
      - AUTH_RATE_LIMIT_WINDOW=900000  # Auth attempts window (15 minutes)
      - AUTH_RATE_LIMIT_MAX=5          # Max auth attempts per window
      
      # OpenID Connect (OIDC) SSO Configuration
      # - ENABLE_OIDC=false
      # - OIDC_ISSUER=
      # - OIDC_CLIENT_ID=
      # - OIDC_CLIENT_SECRET=
      # - OIDC_CALLBACK_URL=
      # - OIDC_SCOPE=openid profile email
    volumes:
      # Issued certs + app data
      - ${MOUNTPOINT1}:/app/data
      - ${MOUNTPOINT2}:/app/certificates
      # Persist the per-container mkcert Root CA across container restarts.
      # As of v4.0.0 the image no longer ships a baked-in CA (every pulled
      # image used to share the same rootCA-key.pem — see CHANGELOG). The
      # CA is generated on first boot inside the container via
      # POST /api/generate-ca, and this volume keeps it across restarts.
      - ${MOUNTPOINT3}:/home/nodejs/.local/share/mkcert
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
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
output_note "Please Note:"
output_note "Use the following credentials to login:"
output_note "User:  admin"
output_note "Pass:  4dm1nP4ssw0rd!"
output_null
output_warn "Change the Default Password after first login !!"
output_null
output_info "${APP_FULL_NAME} can be accessed via following URL:"
output_null
output_text "http://localhost:${APP_PORT}"
output_text "or"
output_text "http://${HOST_IP}:${APP_PORT}"
output_null
output_info "Note: This Container WILL NOT be handled by Traefik!"
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
