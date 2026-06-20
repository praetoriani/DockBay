#!/usr/bin/env bash
cat << 'SCRIPT-INFO' > /dev/null
This Shell Script will install & configure the following App: Password Pusher
Place this script in /usr/local/bin make it executable and run it with sudo privileges
URL: https://docs.pwpush.com/
⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
TEST RESULT:   ✓ VERIFIED WORKING
⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
CREATED ON:    31.05.2026
⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
Script Name:   install-pwpush.sh
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
APP_FULL_NAME="Password Pusher"                     # Full name of the App that will be installed (only used for console output)
APP_NAME="pwpush"                                   # The folder name of the App (do not use spaces! only use lowercase and - or _ )
APP_SERVICE="PasswordPush"                          # The Name of the Service (Container Name) for the Compose File
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
APP_USERNAME="it-crew"                              # The Username used for basic auth middleware
APP_PASSWORD="iXn%8ThJ*gMs+9u"                      # The Password used for basic auth middleware
#------------------------------------------------------------------------------------------------------------------------------------------------------
# NETWORK CONFIGURATION
APP_PORT="82"                                       # This is the Port Number which will be exposed for public access
TCP_PORT="80"                                       # This is the Port Number the Docker Container uses internally
APP_IP="172.24.0.18"                                # The (fixed) IP for the Docker Container (Gateway must already exist!)
APP_DOMAIN="pwpush.localhost"                       # This is the Domain/URL Traefik is going to use to expose this app
#------------------------------------------------------------------------------------------------------------------------------------------------------
# VOLUME & LOCAL MOUNT POINTS
DATA_VOLUME="PWPushData"                            # Name of the Docker Volume -> Only needed if app needs a Docker Volume!
MOUNTPOINTDATA="${APP_PATH}/data"                   # Local Mountpoint for: App-Data


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

# Creating new mountpoint using function from wsl2-lib.sh
CreateLocalMountPoint $MOUNTPOINTDATA 775 1000

# Creating new Volume using function from wsl2-lib.sh
CreateNewDockerVolume $DATA_VOLUME $APP_NAME

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

# Create Compose File using function from wsl2-lib.sh
CreateNewFile "${APP_PATH}/${APP_COMPOSE}" "Y"

output_info "ℹ️ Writing content to ${APP_COMPOSE}. Please wait ..."
# Write new content to the compose file
cat << EOF > $APP_PATH/$APP_COMPOSE
x-env: &x-env
  environment:
    # --- Security & TLS ---
    PWPUSH_MASTER_KEY: "17a71174d78c4b5fb0f7eed51850428d75b25d3ff96f1602b6fc61bb1e8ac527"

    # --- Features ---
    PWP__ENABLE_URL_PUSHES: "false"
    PWP__ENABLE_FILE_PUSHES: "false"
    PWP__ENABLE_QR_PUSHES: "false"
    PWP__ALLOW_ANONYMOUS: "true"

    # --- Deployment & URL ---
    PWP__HOST_DOMAIN: "localhost"
    # PWP__HOST_PROTOCOL: "https"
    # PWP__OVERRIDE_BASE_URL: ""
    # PWP__ALLOWED_HOSTS: ""
    # PWP__TRUSTED_PROXIES: ""
    # PWP__CLOUDFLARE_PROXY: "false"

    # --- Authentication ---
    PWP__LOGIN_SESSION_TIMEOUT: "2 hours"
    PWP__DISABLE_SIGNUPS: "true"
    # PWP__DISABLE_LOGINS: "false"
    # PWP__SIGNUP_EMAIL_REGEXP: ""
    # PWP__ENABLE_USER_ACCOUNT_EMAILS: "false"  # Make sure to set SMTP settings below first or error 500s shall be granted to you!

    # --- Mail (required for logins / account emails) ---
    # See the documentation: https://docs.pwpush.com/docs/self-hosted-configuration/#smtp-when-you-need-mail
    # PWP__MAIL__RAISE_DELIVERY_ERRORS: "false"
    # PWP__MAIL__SMTP_ADDRESS: ""
    # PWP__MAIL__SMTP_DOMAIN: ""
    # PWP__MAIL__SMTP_PORT: "587"
    # PWP__MAIL__SMTP_AUTHENTICATION: ""
    # PWP__MAIL__SMTP_USER_NAME: ""
    # PWP__MAIL__SMTP_PASSWORD: ""
    # PWP__MAIL__SMTP_ENABLE_STARTTLS_AUTO: "true"
    # PWP__MAIL__SMTP_OPEN_TIMEOUT: "10"
    # PWP__MAIL__SMTP_READ_TIMEOUT: "10"
    # PWP__MAIL__MAILER_SENDER: ""

    # --- Push: password (pw) ---
    PWP__PW__EXPIRE_AFTER_DAYS_DEFAULT: "1"
    PWP__PW__EXPIRE_AFTER_DAYS_MIN: "1"
    PWP__PW__EXPIRE_AFTER_DAYS_MAX: "3"
    PWP__PW__EXPIRE_AFTER_VIEWS_DEFAULT: "1"
    PWP__PW__EXPIRE_AFTER_VIEWS_MIN: "1"
    PWP__PW__EXPIRE_AFTER_VIEWS_MAX: "3"
    PWP__PW__ENABLE_RETRIEVAL_STEP: "false"
    PWP__PW__RETRIEVAL_STEP_DEFAULT: "false"
    PWP__PW__ENABLE_DELETABLE_PUSHES: "true"
    PWP__PW__DELETABLE_PUSHES_DEFAULT: "true"
    PWP__PW__ENABLE_BLUR: "true"

    # --- Push: URL ---
    # PWP__URL__EXPIRE_AFTER_DAYS_DEFAULT: "7"
    # PWP__URL__EXPIRE_AFTER_VIEWS_DEFAULT: "5"
    # PWP__URL__ENABLE_RETRIEVAL_STEP: "true"
    # PWP__URL__RETRIEVAL_STEP_DEFAULT: "false"

    # --- Push: files ---
    PWP__FILES__STORAGE: "local" # See: https://docs.pwpush.com/docs/self-hosted-configuration/#file-storage-backends
    # PWP__FILES__EXPIRE_AFTER_DAYS_DEFAULT: "7"
    # PWP__FILES__EXPIRE_AFTER_VIEWS_DEFAULT: "5"
    # PWP__FILES__ENABLE_RETRIEVAL_STEP: "true"
    # PWP__FILES__RETRIEVAL_STEP_DEFAULT: "false"
    # PWP__FILES__ENABLE_DELETABLE_PUSHES: "true"
    # PWP__FILES__DELETABLE_PUSHES_DEFAULT: "true"
    # PWP__FILES__BLUR: "true"
    # PWP__FILES__MAX_FILE_UPLOADS: "10"
    # S3: PWP__FILES__S3__ENDPOINT, ACCESS_KEY_ID, SECRET_ACCESS_KEY, REGION, BUCKET
    # GCS: PWP__FILES__GCS__PROJECT, CREDENTIALS, BUCKET, IAM, GSA_EMAIL
    # Azure: PWP__FILES__AS__STORAGE_ACCOUNT_NAME, STORAGE_ACCESS_KEY, CONTAINER

    # --- Push: QR ---
    # PWP__QR__EXPIRE_AFTER_DAYS_DEFAULT: "7"
    # PWP__QR__EXPIRE_AFTER_VIEWS_DEFAULT: "5"
    # PWP__QR__ENABLE_RETRIEVAL_STEP: "true"
    # PWP__QR__RETRIEVAL_STEP_DEFAULT: "false"
    # PWP__QR__ENABLE_DELETABLE_PUSHES: "true"
    # PWP__QR__DELETABLE_PUSHES_DEFAULT: "true"

    # --- Password generator (gen) ---
    # PWP__GEN__HAS_NUMBERS: "true"
    # PWP__GEN__TITLE_CASED: "true"
    # PWP__GEN__USE_SEPARATORS: "true"
    # PWP__GEN__CONSONANTS: ""
    # PWP__GEN__VOWELS: ""
    # PWP__GEN__SEPARATORS: ""
    # PWP__GEN__MAX_SYLLABLE_LENGTH: "3"
    # PWP__GEN__MIN_SYLLABLE_LENGTH: "1"
    # PWP__GEN__SYLLABLES_COUNT: "3"

    # --- Branding & UI ---
    # PWP__BRAND__TITLE: ""
    # PWP__BRAND__TAGLINE: ""
    # PWP__BRAND__DISCLAIMER: ""
    # PWP__BRAND__SHOW_FOOTER_MENU: "true"
    # PWP__SHOW_VERSION: "true"
    # PWP__SHOW_GDPR_CONSENT_BANNER: "false"
    # PWP__THEME: "default" # See: https://docs.pwpush.com/docs/rebranding/#themes
    # PWP_PRECOMPILE: "false"  # DEPRECATED. Precompilation now happens automatically when PWP__THEME is set. Keeping for backward compatibility.

    # --- Locale ---
    PWP__DEFAULT_LOCALE: "de"

    # --- Security & infra ---
    # PWP__SECURE_COOKIES: "false"
    # PWP__THROTTLING__MINUTE: "120"
    # PWP__THROTTLING__SECOND: "60"
    # PWP__PURGE_AFTER: "disabled"

    # --- Logging ---
    PWP__LOG_LEVEL: "warn"
    PWP__LOG_TO_STDOUT: "true"

    # --- Docker / process ---
    # PWP__NO_WORKER: "true"   # Web only (no background worker)

services:
  ${APP_SERVICE}:
    # "latest" is mostly reliable; use "stable" for well tested releases.
    image: docker.io/pglombardo/pwpush:stable
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

      # Basic Auth Middleware
      #- "traefik.http.middlewares.${APP_NAME}-auth.basicauth.users=${AUTH_HASH}"
      #- "traefik.http.routers.${APP_NAME}.middlewares=${APP_NAME}-auth@docker"
      #- "traefik.http.routers.${APP_NAME}.middlewares=${APP_NAME}-auth"
      #- "traefik.http.routers.${APP_NAME}-secure.middlewares=${APP_NAME}-auth@docker"
      #- "traefik.http.routers.${APP_NAME}-secure.middlewares=${APP_NAME}-auth"

    ports:
      # - "443:443"
      - "${APP_PORT}:${TCP_PORT}" # To support older browsers
      # - "5100:5100" # High port if you host pwpush behind a proxy (HTTP)
    networks:
      apphost:
        ipv4_address: ${APP_IP}

    platform: linux/amd64
    volumes:
      - ${DATA_VOLUME}:/opt/PasswordPusher/storage
      - ${MOUNTPOINTDATA}:/opt/PasswordPusher/storage
    
    healthcheck:
      # Inside the container, the app listens on port 5100.
      # Port 443 above is the externally exposed HTTPS endpoint.
      test: ["CMD", "curl", "-f", "http://localhost:5100/up"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    
    <<: *x-env
    # Optional external env file support (alternative to setting values above directly).
    # env_file:
    #   - .env

networks:
  apphost:
    external: true

# Persists SQLite DB and file uploads. To use a host path instead, replace the
# pwpush-storage service volume with: - /path/on/host:/opt/PasswordPusher/storage
volumes:
  ${DATA_VOLUME}:
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

# Following code will execute after 'i' section was executed
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
output_text "📌 Please note:"
output_text "The access to  ${APP_DOMAIN}  is currently secured"
output_text "by Traefik Proxy using Basic Authentication Middleware."
output_text "Use the following credentials for login:"
output_text "Username:  ${APP_USERNAME}"
output_text "Password:  ${APP_PASSWORD}"
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
