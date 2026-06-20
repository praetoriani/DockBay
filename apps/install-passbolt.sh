#!/usr/bin/env bash
cat << 'SCRIPT-INFO' > /dev/null
This Shell Script will install & configure the following App: Passbolt Password Manager
Place this script in /usr/local/bin make it executable and run it with sudo privileges
URL: https://www.passbolt.com/
⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
TEST RESULTS:  SUCCESSFULLY TESTED ON WSL2/DEBIAN ON 08.06.2026
⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
Script Name:   install-passbolt.sh
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
APP_FULL_NAME="Passbolt Password Manager"           # Full name of the App that will be installed (only used for console output)
APP_NAME="passbolt"                                 # The folder name of the App (do not use spaces! only use lowercase and - or _ )
APP_SERVICE="Passbolt"                              # The Name of the Service (Container Name) for the Compose File
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
TRAEFIK_LOCATION="/opt/docker/sysapp/traefik"       # The full path to the root folder of the Traefik Installation Directory
#------------------------------------------------------------------------------------------------------------------------------------------------------
# NETWORK CONFIGURATION
APP_PORT="84"                                       # This is the Port Number which will be exposed for public access
TCP_PORT="80"                                       # This is the Port Number the Docker Container uses internally
APP_IP="172.24.0.19"                                # The (fixed) IP for the Docker Container (Gateway must already exist!)
SQL_IP="172.30.0.5"                                 # The (fixed) IP for the db-cluster Network
APP_DB_NAME="PassboltDB"                            # This is the Name of the Database which is used by the Container
APP_DOMAIN="passbolt.localhost"                     # This is the Domain/URL Traefik is going to use to expose this app
#------------------------------------------------------------------------------------------------------------------------------------------------------
# VOLUME & LOCAL MOUNT POINTS
DATA_VOLUME_GPG="PassboltDataGPG"                   # Name of the Docker Volume -> Only needed if app needs a Docker Volume!
DATA_VOLUME_JWT="PassboltDataJWT"                   # Name of the Docker Volume -> Only needed if app needs a Docker Volume!
MOUNTPOINTCERTS="${APP_PATH}/certs"                 # Local Mountpoint for: SSL Certificates (if needed)
SSLCRT="${MOUNTPOINTCERTS}/passbolt.crt.pem"
SSLKEY="${MOUNTPOINTCERTS}/passbolt.key.pem"


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
output_warn "${APP_FULL_NAME} is connected to the Maria Database"
output_warn "inside the DB Cluster. ${APP_FULL_NAME} needs the following"
output_warn "Database inside your Maria Database Host: '${APP_DB_NAME}'"
output_warn ""
output_warn "Please make sure that this Database exists, before running"
output_warn "the container for the first time after installation!"
output_null
output_text "Please verify that the above informations are correct."
read -n 1 -s -r -p $'\033[1;38;5;244mPress any key to continue or CTRL+C to cancel ...\033[0m' && echo ""
output_null

# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# MAIN SCRIPT EXECUTION
: << 'EOF'
output_warn "⚠️ The Installation of ${APP_FULL_NAME} requires Traefik Proxy!"
output_warn "The Traefik Installation Directory was set to:"
output_text "${TRAEFIK_LOCATION}"
output_warn "We need to verify, that this location exists!"
output_null
VerifyPath "${TRAEFIK_LOCATION}/" "exit"
output_null
output_okay "✅ Done. Traefik seems to be installed."
output_null
EOF

output_info "ℹ️ Creating ${APP_FULL_NAME} Directory structure. Please wait ..."

# Using function from wsl2-lib.sh
CreateNewPath $APP_PATH 775 1000

# Creating new mountpoints using function from wsl2-lib.sh
CreateLocalMountPoint $MOUNTPOINTCERTS 775 1000

# PREVIOUSLY USED TO CREATE A CERTIFICATE FOR PASSBOLT.
# BUT THIS TASK WILL BE DONE DURINT INSTALLATION OF TRAEFIK !!
cat << 'COMMENT' > /dev/null
# ----- BEGINN CREATING CERTIFICATE AND KEY FOR PASSBOLT --------------------------------------------------
# FOLLOWING SECTION IS VERY SPECIAL TO PASSBOLT! WE PREVIOUSLY VERIFIED THAT TRAEFIK IS INSTALLED.
# NOW WE HAVE TO CREATE NEW SIGNED CERTS FOR PASSBOLD BASED ON THE ROOT CA OF TRAEFIK!
output_info "ℹ️ Searching for Traefik Root-CA. Please wait ..."
# THE FOLLOWING FILES ARE IMPORTANT TO SIGN OUR CERT/KEY
VerifyFile "${TRAEFIK_LOCATION}/certs/rootCA.pem" "exit"
VerifyFile "${TRAEFIK_LOCATION}/certs/rootCA.key" "exit"
output_okay "✅ Looks good. Traefik Root-CA found."

output_info "ℹ️ Switching to Passbolt Certificate Directory ..."
cd $MOUNTPOINTCERTS

output_info "ℹ️ Copying ${MOUNTPOINTCERTS}/rootCA.pem ..."
sudo cp "${TRAEFIK_LOCATION}/certs/rootCA.pem" "${MOUNTPOINTCERTS}/rootCA.pem"
# Get the file size by using function from wsl2-lib.sh
# Check if the size is 0 byte
if [ $(GetFileSize "${MOUNTPOINTCERTS}/rootCA.pem") -eq 0 ]; then
  output_fail "🛑 Failed to copy ${MOUNTPOINTCERTS}/rootCA.pem."
  output_fail "Script $0 exiting ... "
  output_fail "---------------------------------------------------------------------------"
  output_null
  read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
  exit 1
else
  output_okay "✅ Done. ${MOUNTPOINTCERTS}/rootCA.pem successfully copied."
  output_null
fi

output_info "ℹ️ Copying ${MOUNTPOINTCERTS}/rootCA.key ..."
sudo cp "${TRAEFIK_LOCATION}/certs/rootCA.key" "${MOUNTPOINTCERTS}/rootCA.key"
# Get the file size by using function from wsl2-lib.sh
# Check if the size is 0 byte
if [ $(GetFileSize "${MOUNTPOINTCERTS}/rootCA.key") -eq 0 ]; then
  output_fail "🛑 Failed to copy ${MOUNTPOINTCERTS}/rootCA.key."
  output_fail "Script $0 exiting ... "
  output_fail "---------------------------------------------------------------------------"
  output_null
  read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
  exit 1
else
  output_okay "✅ Done. ${MOUNTPOINTCERTS}/rootCA.key successfully copied."
  output_null
fi

output_info "ℹ️ Creating Key file for Passbolt ..."
openssl genrsa -out passbolt.key 2048

output_info "ℹ️ Creating SAN Config for Passbolt ..."
CreateNewFile "${MOUNTPOINTCERTS}/passbolt.san.cnf" "Y"

output_info "ℹ️ Writing Content to ${MOUNTPOINTCERTS}/passbolt.san.cnf ..."
#cat << EOF > $MOUNTPOINTCERTS/passbolt.san.cnf
#[req]
#prompt = no
#distinguished_name = dn
#req_extensions = req_ext
#
#[dn]
#C=DE
#ST=Bayern
#L=München
#O=DockerHub
#OU=DevHive
#CN=passbolt.app
#
#[req_ext]
#subjectAltName = @alt_names
#
#[alt_names]
#DNS.1 = passbolt.app
#DNS.2 = passbolt.local
#DNS.3 = passbolt.localhost
#IP.1  = 127.0.0.1
#IP.2  = 172.26.229.93
#EOF
# Check if the size is 0 byte
if [ $(GetFileSize "${MOUNTPOINTCERTS}/passbolt.san.cnf") -eq 0 ]; then
  output_fail "🛑 Failed to write to ${MOUNTPOINTCERTS}/passbolt.san.cnf."
  output_fail "Script $0 exiting ... "
  output_fail "---------------------------------------------------------------------------"
  output_null
  read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
  exit 1
else
  output_okay "✅ Done. ${MOUNTPOINTCERTS}/passbolt.san.cnf successfully set."
  output_null
fi

output_info "ℹ️ Creating CSR for Passbolt ..."
openssl req -new -key passbolt.key -out passbolt.csr -config passbolt.san.cnf

output_info "ℹ️ Creating self signed Certificate for Passbolt ..."
openssl x509 -req -in passbolt.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out passbolt.crt -days 397 -sha256 -extfile passbolt.san.cnf -extensions req_ext

output_info "ℹ️ Verifying Certificate and Key for Passbolt ..."
VerifyFile "${MOUNTPOINTCERTS}/passbolt.crt" "exit"
VerifyFile "${MOUNTPOINTCERTS}/passbolt.key" "exit"
output_info "ℹ️ Preparing files for Passbolt ..."
sudo cp "passbolt.crt" "${SSLCRT}"
sudo cp "passbolt.key" "${SSLKEY}"
VerifyFile "${SSLCRT}" "exit"
VerifyFile "${SSLKEY}" "exit"
output_okay "✅ Done. Signed Certificate and Key for Passbolt successfully created."
output_info "ℹ️ Cleaning up ..."
sudo find . -maxdepth 1 -type f ! -name $SSLCRT ! -name $SSLKEY -delete
output_okay "✅ Done."
output_null
# ----- FINISH CREATING CERTIFICATE AND KEY FOR PASSBOLT --------------------------------------------------

output_info "ℹ️ Trying to copy Passbolt Certificate and Key to Traefik Cert Store"
sudo cp "${SSLCRT}" "${TRAEFIK_LOCATION}/certs/passbolt.crt"
sudo cp "${SSLKEY}" "${TRAEFIK_LOCATION}/certs/passbolt.key"
VerifyFile "${TRAEFIK_LOCATION}/certs/passbolt.crt" "warn"
VerifyFile "${TRAEFIK_LOCATION}/certs/passbolt.key" "warn"
COMMENT


# Creating new Docker Volume using function from wsl2-lib.sh
CreateNewDockerVolume $DATA_VOLUME_GPG $APP_NAME

# Creating new Docker Volume using function from wsl2-lib.sh
CreateNewDockerVolume $DATA_VOLUME_JWT $APP_NAME

# Create Compose File using function from wsl2-lib.sh
CreateNewFile "${APP_PATH}/${APP_COMPOSE}" "Y"
# Write new content to the compose file
output_info "ℹ️ Writing content to ${APP_COMPOSE}. Please wait ..."
cat << EOF > $APP_PATH/$APP_COMPOSE
services:
#  db:
#    image: mariadb:10.11
#    restart: unless-stopped
#    environment:
#      MYSQL_RANDOM_ROOT_PASSWORD: "true"
#      MYSQL_DATABASE: "passbolt"
#      MYSQL_USER: "passbolt"
#      MYSQL_PASSWORD: "P4ssb0lt"
#    volumes:
#      - database_volume:/var/lib/mysql

  ${APP_SERVICE}:
    image: passbolt/passbolt:latest-ce
    #Alternatively you can use rootless:
    #image: passbolt/passbolt:latest-ce-non-root
    container_name: ${APP_SERVICE}
    restart: unless-stopped

    # Following Section is only important for Traefik Proxy
    #labels:
    #  - "traefik.enable=true"
    #
    #  # Router for HTTP
    #  - "traefik.http.routers.${APP_NAME}.rule=Host(\`${APP_DOMAIN}\`)"
    #  - "traefik.http.routers.${APP_NAME}.entrypoints=web"
    #
    #  # Service → internal Port of the Container
    #  - "traefik.http.services.${APP_NAME}.loadbalancer.server.port=${TCP_PORT}"
    #
    #  # Router for HTTPS
    #  - "traefik.http.routers.${APP_NAME}-secure.rule=Host(\`${APP_DOMAIN}\`)"
    #  - "traefik.http.routers.${APP_NAME}-secure.entrypoints=websecure"
    #  - "traefik.http.routers.${APP_NAME}-secure.tls=true"

    ports:
      - ${APP_PORT}:${TCP_PORT}
    networks:
      apphost:
        ipv4_address: ${APP_IP}
      db-cluster:
        ipv4_address: ${SQL_IP}
    
    environment:
      # General Passbolt Configuration
      APP_FULL_BASE_URL: http://${APP_DOMAIN}
      #APP_FULL_BASE_URL: http://localhost:${APP_PORT}
      APP_DEFAULT_LOCALE: 'de_DE'
      APP_DEFAULT_TIMEZONE: 'Europe/Berlin'
      PASSBOLT_CHECK_DOMAIN_MISMATCH: false
      # Database Configuration
      DATASOURCES_DEFAULT_HOST: "mariadb"
      DATASOURCES_DEFAULT_USERNAME: "root"
      DATASOURCES_DEFAULT_PASSWORD: "Xg!8vQ-S9hYeV5Xe"
      DATASOURCES_DEFAULT_DATABASE: "${APP_DB_NAME}"
    
    volumes:
      - ${DATA_VOLUME_GPG}:/etc/passbolt/gpg
      - ${DATA_VOLUME_JWT}:/etc/passbolt/jwt
      # USE THESE ONLY OF YOU'RE PLANNING TO USE HTTPS/SSL/TLS
      #- ${SSLCRT}:/etc/ssl/certs/certificate.crt:ro
      #- ${SSLKEY}:/etc/ssl/certs/certificate.key:ro
    
    command:
      [
        "/usr/bin/wait-for.sh",
        "-t",
        "0",
        "MariaDB-Host:3306",
        "--",
        "/docker-entrypoint.sh",
      ]

networks:
  apphost:
    external: true
  db-cluster:
    external: true
volumes:
  ${DATA_VOLUME_GPG}:
    external: true
  ${DATA_VOLUME_JWT}:
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


output_okay "✅ Done."
cat << 'COMMENT' > /dev/null

# PASSBOLT SPECIAL!!
# WE NEED TO CREATE A NEW ADMIN USER!
output_info "ℹ️ Creating Admin User for ${APP_FULL_NAME}. Please wait ..."
sleep 2.0
output_null
docker compose -f $APP_COMPOSE \
exec $APP_SERVICE su -m -c "/usr/share/php/passbolt/bin/cake \
  passbolt register_user \
    -u admin@passbolt.local \
    -f root \
    -l admin \
    -r admin" -s /bin/sh www-data
output_null
output_okay "✅ Done."
output_okay "   User 'admin' successfully created."
output_okay "   E-Mail:       admin@passbolt.local"
output_okay "   First Name:   root"
output_okay "   Last Name:    admin"
output_null
output_info "ℹ️ Use the URL shown above to finish First Time Setup and Registration."
output_null
COMMENT

# Following code will execute after 'i' section was executed
output_info "$0 finished."
output_null
output_info "${APP_FULL_NAME} can be accessed via following URL:"
output_null
output_text "http://localhost:${APP_PORT}"
output_text "or"
output_text "http://${APP_DOMAIN}"
output_text "or"
output_text "http://${HOST_IP}:${APP_PORT}"
output_null
output_text "Please copy and paste the following code into your shell:"
output_null
output_text "cd ${APP_PATH} && \\"
output_text "docker compose -f $APP_COMPOSE \\"
output_text "exec $APP_SERVICE su -m -c \"/usr/share/php/passbolt/bin/cake \\"
output_text "  passbolt register_user \\"
output_text "    -u admin@passbolt.local \\"
output_text "    -f root \\"
output_text "    -l admin \\"
output_text "    -r admin\" -s /bin/sh www-data"
output_null
output_null
#output_info "Note: This Container will be handled by Traefik!"
#output_info "→ http://${APP_DOMAIN}"
#output_info "→ https://${APP_DOMAIN}"
#output_null
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
