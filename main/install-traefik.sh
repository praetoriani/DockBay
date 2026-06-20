#!/usr/bin/env bash
# This Shell Script will install & configure the following App: Traefik Proxy
# Place this script in /usr/local/bin make it executable and run it with sudo privileges
# URL: https://github.com/louislam/uptime-kuma
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
# TEST RESULTS:  ✓ SUCCESSFULLY TESTED ON WSL2/DEBIAN ON 08.06.2026
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
# Script Name:   install-traefik.sh
# Last Update:   08.06.2026
# Written by:    Praetoriani
# Website:       https://github.com/praetoriani
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆

# Load the WSL2 Library (important for this script)
CurrentScriptLocation="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"         # ← Gets the full path to the current location
source $CurrentScriptLocation/dockbay.lib.sh

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
APP_FULL_NAME="Traefik Proxy"                       # Full name of the App that will be installed (only used for console output)
APP_NAME="traefik"                                  # The folder name of the App (do not use spaces! only use lowercase and - or _ )
APP_SERVICE="Traefik"                               # The Name of the Service (Container Name) for the Compose File
APP_COMPOSE="${APP_NAME}-compose.yml"               # The name of the Docker Compose file (do not change this!)
DOCKERDIR="${DOCKBAY["ROOTPATH"]}"                  # Absolute path to the root directory of the docker stacks
if [ "$SETUP_LOCATION" = "EMPTY"]; then
  APP_PATH="${DOCKBAY["SYSSTACK"]}/${APP_NAME}"     # Absolute path to the Installation Directory
else
  APP_PATH="${SETUP_LOCATION}/${APP_NAME}"          # Absolute path to the Installation Directory
fi
#------------------------------------------------------------------------------------------------------------------------------------------------------
# ADDITIONAL CONFIGURATION
APP_ENV_FILE=".env"                                 # The name of the .env-file for the Docker Compose File
APP_CNF_FILE="tls.yaml"                             # This file is for the dynamic TLS configuration of Traefik
#------------------------------------------------------------------------------------------------------------------------------------------------------
# NETWORK CONFIGURATION
APP_PORT="80"                                       # This is the Port Number which will be exposed for public access
TCP_PORT="80"                                       # This is the Port Number the Docker Container uses internally
SSL_APP_PORT="443"                                  # This is the Port Number which will be exposed for public access
SSL_TCP_PORT="443"                                  # This is the Port Number the Docker Container uses internally
APP_IP="172.24.1.1"                                 # The (fixed) IP for the Docker Network: apphost
TNP_IP="172.40.1.1"                                 # The (fixed) IP for the Docker Network: traefik-proxy
WAI_IP="172.40.1.2"                                 # The (fixed) IP for the WhoAmI-Container
#------------------------------------------------------------------------------------------------------------------------------------------------------
# SSL & AUTH CONFIGURATION
TRAEFIK_USER="traefik-admin"                        # The Username for the default admin account ← CHANGE THIS!!
TRAEFIK_PASS="td2Vk&e0p+Q#zG3n"                     # The Password for the default admin account ← CHANGE THIS!!

declare -A SSLCFG                                   # ← Stores important informations about Root-CA etc.
SSLCFG["ROOTCAKEY"]="rootCA.key"                    # ← Private Key for Root-CA
SSLCFG["ROOTCAPEM"]="rootCA.pem"                    # ← Self-Signed Root-CA (this is needed to issue/sign other certificates)
SSLCFG["ROOTCACRT"]="rootCA.crt"                    # ← Same as rootCA.pem but in a different format
SSLCFG["PROXYKEY"]="traefik.key"                    # ← This is the private key for the Traefik Cert
SSLCFG["PROXYCRT"]="traefik.crt"                    # ← This is the signed, plublic certificate for Traefik
SSLCFG["PROXYSAN"]="traefik.san.cnf"                # ← This is the SAN Configuration for Traefik
SSLCFG["PROXYCSR"]="traefik.csr"                    # ← This is the Certificate Signing Request for Traefik
SSLCFG["BACKUP"]="/usr/local/share/ca-certificates/backup-traefik"

TRAEFIK_ADMURL="admin.traefik.localhost"            # This URL is very important to Traefik, cause this is where your dashboard will be located
TRAEFIK_WHOAMI="whoami.traefik.localhost"           # This URL is very important to Traefik, cause this is where the whoami container is reachable
#------------------------------------------------------------------------------------------------------------------------------------------------------
# VOLUME & LOCAL MOUNT POINTS
MOUNTPOINT_CERT="${APP_PATH}/certs"                 # This folder will hold the SSL Certs for Traefik Proxy
MOUNTPOINT_CONF="${APP_PATH}/config"                # This folder holds the tls.yaml for dynamic TLS configuration


# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# MANDATORY PRE-CHECKS

output_text "Script $0 started ..."
output_text "********************************************************************************"
output_null
output_text "Checking current configuration. Please wait ..."
output_null
sleep 0.5
# Get current config from global array and json
if [ "$(jq -r '.setup.traefikproxy' $SETUPCFGJSON)" = "false" ]; then
    output_text "Traefik Proxy is already installed."
    sleep 0.2
    output_text "Nothing to do."
    sleep 0.2
    output_text "Going back to Main Screen"
    output_null
    sleep 2.0
    exit 0
else
    output_text "Traefik Proxy not found in DockBay Environment."
    output_text "Please proceed to add Traefik Proxy to DockBay."
fi
output_null
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
output_null
output_warn "The Installation of ${APP_FULL_NAME} requires"
output_warn "working installations of 'openssl' and 'apache2-utils'!"
output_warn "Please make sure you have these packages up and running."
output_warn "Otherwise the installation will fail!"
output_null
output_info "To install the required packages, run the following command:"
output_text "sudo apt install openssl apache2-utils -y"
output_null
read -n 1 -s -r -p $'\033[1;38;5;244mPress any key to continue or CTRL+C to cancel ...\033[0m' && echo ""
output_null

# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# MAIN SCRIPT EXECUTION

output_info "ℹ️ Creating ${APP_FULL_NAME} Directory structure. Please wait ..."

# Using function from wsl2-lib.sh
CreateNewPath $APP_PATH 775 1000

# Create additional Mountpoints
CreateLocalMountPoint $MOUNTPOINT_CERT 775 1000
CreateLocalMountPoint $MOUNTPOINT_CONF 775 1000

# Create Config File using function from wsl2-lib.sh
CreateNewFile "${MOUNTPOINT_CONF}/${APP_CNF_FILE}" "Y"

output_info "ℹ️ Writing content to ${APP_CNF_FILE}. Please wait ..."
# Write new content to the file
cat << EOF > $MOUNTPOINT_CONF/$APP_CNF_FILE
tls:
  certificates:
    # --- Traefik Internal Cert/Key Pair
    #- certFile: "certs/local.crt"
    #  keyFile:  certs/local.key
    # --- This is the Root-CA Certificate
    - certFile: certs/${SSLCFG["ROOTCACRT"]}
      keyFile:  certs/${SSLCFG["ROOTCAKEY"]}
    # --- Cert/Key-Pair for:  Traefik
    - certFile: certs/${SSLCFG["PROXYCRT"]}
      keyFile:  certs/${SSLCFG["PROXYKEY"]}
    # --- Cert/Key-Pair for:  Passbolt
    - certFile: certs/passbolt.crt
      keyFile:  certs/passbolt.key
  stores:
    default: {}
EOF
# Get the file size by using function from wsl2-lib.sh
# Check if the size is 0 byte
if [ $(GetFileSize "${MOUNTPOINT_CONF}/${APP_CNF_FILE}") -eq 0 ]; then
  output_fail "🛑 Failed to write new content to ${MOUNTPOINT_CONF}/${APP_CNF_FILE}"
  output_fail "Script $0 exiting ... "
  output_fail "---------------------------------------------------------------------------"
  output_null
  read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
  exit 1
else
  output_okay "✅ Done."
  output_okay "   Content successfully written to ${APP_CNF_FILE}"
  output_null
fi


# ----- Beginn creating Root-CA and SSL Certificates ----------------------------------------
# The following part is very important for Traefik Proxy. The following section creates a new Root-CA and uses it for signing the SSL-Certificates
output_null
output_info "ℹ️ Creating new Root-CA and SSL-Certs for ${APP_FULL_NAME}. Please wait ..."
# switching to the certs directory
output_info "ℹ️ Changing current directory to: ${MOUNTPOINT_CERT}"
cd $MOUNTPOINT_CERT

output_info "ℹ️ Creating private RSA-Key for Root-CA using OpenSSL ..."
openssl genrsa -out "${SSLCFG["ROOTCAKEY"]}" 4096
# Check if the size is 0 byte
if [ $(GetFileSize "${MOUNTPOINT_CERT}/${SSLCFG["ROOTCAKEY"]}") -eq 0 ]; then
  output_fail "🛑 Failed to create ${SSLCFG["ROOTCAKEY"]}"
  output_fail "Script $0 exiting ... "
  output_fail "---------------------------------------------------------------------------"
  output_null
  read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
  exit 1
else
  output_okay "✅ Done. File ${SSLCFG["ROOTCAKEY"]} successfully created."
  output_null
  output_warn "⚠️ Important Information:"
  output_warn "The ${SSLCFG["ROOTCAKEY"]} is your private Key! Never expose it!"
  output_null
fi
sleep 1.0

output_info "ℹ️ Creating self-signed certificate for Root-CA using OpenSSL ..."
#openssl req -x509 -new -nodes -key "${SSLCFG["ROOTCAKEY"]}" -sha256 -days 3650 -out "${SSLCFG["ROOTCAPEM"]}" -subj "/C=DE/ST=Bavaria/L=Munich/O=Praetoriani/CN=*.devhub"
# This is a special Certificate, issued on the name of the local machine (hostname)
openssl req -x509 -new -nodes -key "${SSLCFG["ROOTCAKEY"]}" -sha256 -days 3650 -out "${SSLCFG["ROOTCAPEM"]}" -subj "/C=DE/ST=Bavaria/L=Munich/O=Praetoriani/OU=${MACHINE_NAME}/CN=*.${MACHINE_NAME}.localhost"
# Check if the size is 0 byte
if [ $(GetFileSize "${MOUNTPOINT_CERT}/${SSLCFG["ROOTCAPEM"]}") -eq 0 ]; then
  output_fail "🛑 Failed to create ${SSLCFG["ROOTCAPEM"]}"
  output_fail "Script $0 exiting ... "
  output_fail "---------------------------------------------------------------------------"
  output_null
  read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
  exit 1
else
  output_okay "✅ Done. File ${SSLCFG["ROOTCAPEM"]} successfully created."
  output_null
  output_note "💡 Information:"
  output_note "The ${SSLCFG["ROOTCAPEM"]} is a public certificate and can be used to import it"
  output_note "to the cert store of your system. This is important if you want that"
  output_note "your browser(s) will trust the Traefik Proxy."
  output_note "The ${SSLCFG["ROOTCAPEM"]} is also being used to create and sign own cert/key pairs."
  output_note "So you definitely should keep ${SSLCFG["ROOTCAKEY"]} and ${SSLCFG["ROOTCAPEM"]}"
  output_null
fi
sleep 1.0

output_info "ℹ️ Creating private RSA-Key for Traefik Proxy using OpenSSL ..."
openssl genrsa -out "${SSLCFG["PROXYKEY"]}" 2048
# Check if the size is 0 byte
if [ $(GetFileSize "${MOUNTPOINT_CERT}/${SSLCFG["PROXYKEY"]}") -eq 0 ]; then
  output_fail "🛑 Failed to create ${SSLCFG["PROXYKEY"]}"
  output_fail "Script $0 exiting ... "
  output_fail "---------------------------------------------------------------------------"
  output_null
  read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
  exit 1
else
  output_okay "✅ Done. File ${SSLCFG["PROXYKEY"]} successfully created."
  output_null
fi
sleep 1.0

output_info "ℹ️ Creating SAN Configuration for Traefik Proxy ..."
CreateNewFile "${MOUNTPOINT_CERT}/${SSLCFG["PROXYSAN"]}" "Y"
# Write new content to the file
output_info "ℹ️ Writing SAN Configuration for Traefik Proxy ..."
cat <<EOF > "${MOUNTPOINT_CERT}/${SSLCFG[PROXYSAN]}"
[req]
prompt = no
distinguished_name = dn
req_extensions = req_ext

[dn]
O=Traefik
CN=*.traefik.localhost

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1  = localhost
DNS.2  = *.localhost
DNS.3  = ${MACHINE_NAME}
DNS.4  = *.${MACHINE_NAME}
DNS.5  = *.traefik.localhost
DNS.6  = *.traefik.docker
EOF
# Get the file size by using function from wsl2-lib.sh
# Check if the size is 0 byte
if [ $(GetFileSize "${MOUNTPOINT_CERT}/${SSLCFG["PROXYSAN"]}") -eq 0 ]; then
  output_fail "🛑 Failed to write new content to ${MOUNTPOINT_CERT}/${SSLCFG["PROXYSAN"]}"
  output_fail "Script $0 exiting ... "
  output_fail "---------------------------------------------------------------------------"
  output_null
  read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
  exit 1
else
  output_okay "✅ Done."
  output_okay "   Content successfully written to ${SSLCFG["PROXYSAN"]}"
  output_null
fi
sleep 1.0

output_info "ℹ️ Creating CSR for Traefik Proxy using OpenSSL ..."
openssl req -new -key "${SSLCFG["PROXYKEY"]}" -out "${SSLCFG["PROXYCSR"]}" -config "${SSLCFG["PROXYSAN"]}"
# Check if the size is 0 byte
if [ $(GetFileSize "${MOUNTPOINT_CERT}/${SSLCFG["PROXYCSR"]}") -eq 0 ]; then
  output_fail "🛑 Failed to create ${SSLCFG["PROXYCSR"]}"
  output_fail "Script $0 exiting ... "
  output_fail "---------------------------------------------------------------------------"
  output_null
  read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
  exit 1
else
  output_okay "✅ Done. File ${SSLCFG["PROXYCSR"]} successfully created."
  output_null
fi
sleep 1.0

output_info "ℹ️ Creating signed certificate for Traefik Proxy using OpenSSL ..."
output_null
output_text "OpenSSL:"
output_text "$(openssl x509 -req -in "${SSLCFG["PROXYCSR"]}" -CA "${SSLCFG["ROOTCAPEM"]}" -CAkey "${SSLCFG["ROOTCAKEY"]}" -CAcreateserial -out "${SSLCFG["PROXYCRT"]}" -days 397 -sha256 -extfile "${SSLCFG["PROXYSAN"]}" -extensions req_ext)"
output_null
# Check if the size is 0 byte
if [ $(GetFileSize "${MOUNTPOINT_CERT}/${SSLCFG["PROXYCRT"]}") -eq 0 ]; then
  output_fail "🛑 Failed to create ${SSLCFG["PROXYCRT"]}"
  output_fail "Script $0 exiting ... "
  output_fail "---------------------------------------------------------------------------"
  output_null
  read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
  exit 1
else
  output_okay "✅ Done. File ${SSLCFG["PROXYCRT"]} successfully created."
  output_null
  output_note "💡 Information:"
  output_note "The ${SSLCFG["PROXYCRT"]} is a public certificate. Don't loose it."
  output_null
fi
sleep 1.0

output_okay "✅ Done."
output_okay "All required Certificates successfully created."
output_null

output_info "ℹ️ Registering Root-CA in the trusted certificate store. Please wait ..."
#sudo cp rootCA.pem rootCA.crt
# Register the Root-CA in the system and update the store
OldCert=$(FileLookup "/usr/local/share/ca-certificates/TraefikRootCA.crt")
if [ "$OldCert" = "ok" ]; then
    output_warn "⚠️ Old certificate found in cert store. Removing it ..."
    sudo rm /usr/local/share/ca-certificates/TraefikRootCA.crt
    output_info "ℹ️ Updating certificate store ... "
    sudo update-ca-certificates --fresh
    output_okay "✅ Done."
elif [ "$OldCert" = "xx" ]; then
    output_info "ℹ️ No previous/old certificate found in store."
else
    output_fail "🛑 Failed verifying if TraefikRootCA.crt already exists!"
    output_null
    output_warn "⚠️ Please check the certificate store for TraefikRootCA.crt!"
    output_null
    output_warn "⚠️ You have to make sure that the new TraefikRootCA.crt is"
    output_warn "   registered correctely in the cert store of your System!"
    output_null
fi
output_info "ℹ️ Copying Root-CA to the certificate store ..."
sudo cp "${SSLCFG["ROOTCAPEM"]}" /usr/local/share/ca-certificates/TraefikRootCA.crt
NewCert=$(FileLookup "/usr/local/share/ca-certificates/TraefikRootCA.crt")
if [ "$NewCert" = "ok" ]; then
    output_okay "✅ Done."
    output_info "ℹ️ Updating certificate store. Please wait ..."
    sudo update-ca-certificates --fresh
    output_okay "✅ Done."
    output_null
elif [ "$OldCert" = "xx" ]; then
    output_fail "🛑 Failed copying TraefikRootCA.crt to certificyte store!"
    output_null
    output_warn "⚠️ You have to make sure that the new TraefikRootCA.crt is"
    output_warn "   registered correctely in the cert store of your System!"
    output_null
else
    output_fail "🛑 Failed verifying if TraefikRootCA.crt already exists!"
    output_fail "   → Unexpected error occured, while running following command:"
    output_fail "   → 'sudo cp rootCA.pem /usr/local/share/ca-certificates/TraefikRootCA.crt'"
    output_fail "--------------------------------------------------------------------------------"
    output_null
    output_warn "⚠️ The installation will continue, but please note:"
    output_warn "   → The TraefikRootCA.crt is NOT REGISTERED in your System!"
    output_warn "   → You might have problems/errors using certificates which"
    output_warn "   → were created/signed using rootCA.pem!"
    output_null
fi
output_null

# ----- Finish creating Root-CA and SSL Certificates ----------------------------------------
# Now we need to create/copy the created files to provide local.crt/local.key
# After this step, the ./certs folder contains all required files for Traefik
output_info "ℹ️ Preparing Certificates."
sudo cp "${SSLCFG["ROOTCAPEM"]}" TraefikRootCA.crt         # ← Only for Backup-Purpose ;)
sudo cp "${SSLCFG["ROOTCAPEM"]}" "${SSLCFG["ROOTCACRT"]}"  # ← For Traefik Import
output_okay "✅ Done."


cat << 'COMMENT' > /dev/null
# ####################################################################################################
# SPECIAL STEP FROM TRAEFIK DOCUMENTATION:
# WITHOUT THIS STEP, TRAEFIK WILL NOT WORK AND WILL NOT BE AVAILABLE AT admin.traefik.localhost !!
# CHECK THE FOLLOWING URL FOR MMORE INFORMATION ABOUT THIS STEP
# https://doc.traefik.io/traefik/setup/docker/#create-a-selfsigned-certificate
#
# THE FOLLOWING COMMAND WILL ISSUE A SELF SIGNED CERTIFICATE FOR  *.traefik.localhost  BUT ...
# → THIS CERTIFICATE WILL ONLY WORK FOR TRAEFIK INTERNALLY. THIS CERTIFICATE IS NOT TRUSTED
#   BY A ROOT-CA! SO YOU WILL STILL GET TRUSTING ISSUES INSIDE YOUR BROWSER, BECAUSE THERE
#   WAS NO ROOT-CA WHO SIGNED THIS CERT. WITH OUT THIS, THE SELF SIGNED CERTIFICATE FOR TRAEFIK
#   WILL NOT BE TRUSTED BECAUSE THE CERTIFICATE CHAIN IS MISSING!
output_info "ℹ️ Creating Self-Signed Certificate for  '*.traefik.localhost' "
output_info "   → The local.key/local.crt pair won't be trusted by your browser."
output_info "   → because this Certificate wasn't signed by a Root-CA Authority."
output_null
output_text "OpenSSL:"
output_text "$(openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout local.key -out local.crt -subj "/O=Traefik/CN=*.traefik.localhost")"
output_null
sleep 1.0
# IF WE INCLUDE THESE TWO FILES INSIDE THE tls.yaml THEN TRAEFIK WILL WORK !
# ####################################################################################################
COMMENT


#output_info "ℹ️ Cleaning up."
#find . -maxdepth 1 -type f ! -name 'rootCA.pem' ! -name 'rootCA.key' ! -name 'rootCA.srl' ! -name $SSL_CRT_FILE ! -name $SSL_KEY_FILE ! -name 'traefikproxy.san.cnf' -delete
output_text "$(sudo ls -silknah -R -1 $MOUNTPOINT_CERT)"
output_null
output_okay "✅ Done."
output_okay "✅ Root-CA successfully created."
output_okay "✅ Cert/Key for Traefik Proxy successfully issued & signed."
output_null
sleep 1.0

# ----- Start creating signed Cert/Key for Passbolt ----------------------------------------
output_info "ℹ️ Creating new private key for:  Passbolt"
openssl genrsa -out passbolt.key 2048
if [ $(GetFileSize "${MOUNTPOINT_CERT}/passbolt.key") -eq 0 ]; then
  output_fail "🛑 Failed to create passbolt.key"
  output_fail "Script $0 exiting ... "
  output_fail "---------------------------------------------------------------------------"
  output_null
  read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
  exit 1
else
  output_okay "✅ Done. File passbolt.key successfully created."
  output_null
fi
sleep 1.0

output_info "ℹ️ Creating SAN Configuration for:  Passbolt"
CreateNewFile "${MOUNTPOINT_CERT}/passbolt.san.cnf" "Y"
output_info "ℹ️ Writing Content to ${MOUNTPOINT_CERT}/passbolt.san.cnf ..."
cat << EOF > $MOUNTPOINT_CERT/passbolt.san.cnf
[req]
prompt = no
distinguished_name = dn
req_extensions = req_ext

[dn]
O=Traefik
CN=passbolt.localhost

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = passbolt.localhost
DNS.2 = passbolt.${MACHINE_NAME}
DNS.3 = app.passbolt.localhost
DNS.4 = passbolt.docker
IP.1  = 127.0.0.1
IP.2  = ${HOST_IP}
EOF
# Check if the size is 0 byte
if [ $(GetFileSize "${MOUNTPOINT_CERT}/passbolt.san.cnf") -eq 0 ]; then
  output_fail "🛑 Failed to write to ${MOUNTPOINT_CERT}/passbolt.san.cnf."
  output_fail "Script $0 exiting ... "
  output_fail "---------------------------------------------------------------------------"
  output_null
  read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
  exit 1
else
  output_okay "✅ Done. passbolt.san.cnf successfully set."
  output_null
fi
sleep 1.0

output_info "ℹ️ Creating new CSR for:  Passbolt"
openssl req -new -key passbolt.key -out passbolt.csr -config passbolt.san.cnf
if [ $(GetFileSize "${MOUNTPOINT_CERT}/passbolt.csr") -eq 0 ]; then
  output_fail "🛑 Failed to create passbolt.csr"
  output_fail "Script $0 exiting ... "
  output_fail "---------------------------------------------------------------------------"
  output_null
  read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
  exit 1
else
  output_okay "✅ Done. File passbolt.csr successfully created."
  output_null
fi
sleep 1.0

output_info "ℹ️ Creating signed (by Root-CA) Certificate for:  Passbolt"
output_null
output_text "OpenSSL:"
output_text "$(openssl x509 -req -in passbolt.csr -CA "${SSLCFG["ROOTCAPEM"]}" -CAkey "${SSLCFG["ROOTCAKEY"]}" -CAcreateserial -out passbolt.crt -days 397 -sha256 -extfile passbolt.san.cnf -extensions req_ext)"
output_null
if [ $(GetFileSize "${MOUNTPOINT_CERT}/passbolt.crt") -eq 0 ]; then
  output_fail "🛑 Failed to create passbolt.crt"
  output_fail "Script $0 exiting ... "
  output_fail "---------------------------------------------------------------------------"
  output_null
  read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to exit...\033[0m' && echo ""
  exit 1
else
  output_okay "✅ Done. File passbolt.crt successfully created."
  output_null
fi
sleep 1.0

output_info "ℹ️ Converting Cert/Key Pair for Passbolt App ... "
sudo cp passbolt.crt passbolt.crt.pem
VerifyFile "${MOUNTPOINT_CERT}/passbolt.crt.pem" "exit"

sudo cp passbolt.key passbolt.key.pem
VerifyFile "${MOUNTPOINT_CERT}/passbolt.key.pem" "exit"

output_text "$(sudo ls -silknah -R -1 $MOUNTPOINT_CERT)"
output_null
output_okay "✅ Done."
output_okay "✅ Cert/Key for Passbolt successfully issued & signed."
output_null
sleep 1.0
# ----- Finish creating signed Cert/Key for Passbolt ---------------------------------------



cat << 'COMMENT' > /dev/null
output_info "ℹ️ Creating Self-Signed Certificate for  'blinko.app' "
output_info "   → The local.key/local.crt pair won't be trusted by your browser."
output_info "   → because this Certificate wasn't signed by a Root-CA Authority."
output_null
output_text "OpenSSL:"
#output_text "$(openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout blinko.key -out blinko.crt -subj "/O=Traefik/CN=blinko.app")"
openssl genrsa -out blinko.key 2048
openssl req -new -key blinko.key -out blinko.csr -subj "/O=Traefik/CN=blinko.app"
openssl x509 -req -in blinko.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out blinko.crt -days 365 -sha512
output_null
sleep 1.0
COMMENT



# ##########################################################################################
# MANDATORY BACKUP-PROCESS
output_info "ℹ️ Creating Backup of all created files. Please wait ..."
output_info "ℹ️ Checking ${SSLCFG["BACKUP"]} ... "
CheckBackup=$(PathLookup "${SSLCFG["BACKUP"]}")
if [ "$CheckBackup" = "ok" ]; then
  output_note "💡 ${SSLCFG["BACKUP"]} exists. Cleaning up ... "
  sudo rm -f "${SSLCFG["BACKUP"]}/*"
  output_okay "✅ Done."
elif [ "$CheckBackup" = "xx" ]; then
  output_info "ℹ️ ${SSLCFG["BACKUP"]} not found. creating it ... "
  sudo mkdir -p "${SSLCFG["BACKUP"]}"
  output_okay "✅ Done."
else
  output_warn "⚠️ Unable to check ${SSLCFG["BACKUP"]} !"
  output_warn "   → Trying to create/override it!"
  sudo mkdir -p "${SSLCFG["BACKUP"]}"
  output_okay "✅ Done."
fi

output_info "ℹ️ Copying all files and creating a backup ... "
sudo cp -a "${MOUNTPOINT_CERT}/." "${SSLCFG["BACKUP"]}/"
if find "${SSLCFG["BACKUP"]}" -mindepth 1 | read; then
  output_okay "✅ Done."
  output_okay "   Backup successfully created."
else
  output_warn "⚠️ Failed creating backup!"
  output_warn "   → Please backup the following folder manually:"
  output_warn "   → ${MOUNTPOINT_CERT}"
fi
output_null
sleep 1.0
# ##########################################################################################



output_info "ℹ️ Creating Hash for default Admin Account. Please wait ..."
TRAEFIK_HASH=$(htpasswd -nb $TRAEFIK_USER "${TRAEFIK_PASS}" | sed -e 's/\$/\$\$/g')
if [ -z "$TRAEFIK_HASH" ]; then
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
  output_null
fi

# Create Compose File using function from wsl2-lib.sh
CreateNewFile "${APP_PATH}/${APP_COMPOSE}" "Y"

output_info "ℹ️ Writing content to ${APP_COMPOSE}. Please wait ..."
# Write new content to the compose file
cat << EOF > $APP_PATH/$APP_COMPOSE
services:
  ${APP_NAME}:
    image: traefik:v3.7
    container_name: ${APP_SERVICE}
    restart: unless-stopped

    ports:
      - "${APP_PORT}:${TCP_PORT}"
      - "${SSL_APP_PORT}:${SSL_TCP_PORT}"
    networks:
     # Connect to the 'traefik_proxy' overlay network for inter-container communication across nodes
      proxy:
      apphost:
        ipv4_address: ${APP_IP}
      traefik-proxy:
        ipv4_address: ${TNP_IP}

    security_opt:
      - no-new-privileges:true

    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./certs:/certs:ro
      - ./config:/dynamic:ro

    command:
      # EntryPoints
      # HTTP Route
      - "--entrypoints.web.address=:80"
      - "--entrypoints.web.http.tls=false"
      #- "--entrypoints.web.http.redirections.entrypoint.to=websecure"
      #- "--entrypoints.web.http.redirections.entrypoint.scheme=https"
      #- "--entrypoints.web.http.redirections.entrypoint.permanent=true"

      # HTTPS Route
      - "--entrypoints.websecure.address=:443"
      - "--entrypoints.websecure.http.tls=true"

      # Attach the static configuration tls.yaml file that contains the tls configuration settings
      - "--providers.file.filename=/dynamic/${APP_CNF_FILE}"

      # Providers 
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--providers.docker.network=proxy"
      # Mantrae Provider
      #- "--providers.http.endpoint=http://mantrae:3000/api/default?token=rdgt7gr4di"
      #- "--providers.http.pollInterval=5s"

      # API & Dashboard 
      - "--api.dashboard=true"
      - "--api.insecure=false"

      # Observability 
      - "--log.level=INFO"
      - "--accesslog=true"
      - "--metrics.prometheus=true"

  # Traefik Dynamic configuration via Docker labels
    labels:
      # Enable self-routing
      - "traefik.enable=true"

      # Dashboard router
      - "traefik.http.routers.dashboard.rule=Host(\`${TRAEFIK_ADMURL}\`)"
      - "traefik.http.routers.dashboard.entrypoints=websecure"
      - "traefik.http.routers.dashboard.service=api@internal"
      - "traefik.http.routers.dashboard.tls=true"

      # Basic-auth middleware
      - "traefik.http.middlewares.dashboard-auth.basicauth.users=${TRAEFIK_HASH}"
      - "traefik.http.routers.dashboard.middlewares=dashboard-auth@docker"

# Whoami application
  whoami:
    image: traefik/whoami
    container_name: whoami
    restart: unless-stopped
    
    networks:
      proxy:
      traefik-proxy:
        ipv4_address: ${WAI_IP}

    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.whoami.rule=Host(\`${TRAEFIK_WHOAMI}\`)"
      - "traefik.http.routers.whoami.entrypoints=websecure"
      - "traefik.http.routers.whoami.tls=true"

networks:
  proxy:
    name: proxy
  apphost:
    external: true
  traefik-proxy:
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
      return 0
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
output_text "$0 finished."
output_null
output_note "💡 Please Note:"
output_note "Use the following credentials to login:"
output_note "User:  ${TRAEFIK_USER}"
output_note "Pass:  ${TRAEFIK_PASS}"
output_null
output_warn "⚠️ Change the Default Settings after first login !!"
output_null
output_text "The Admin Dashboard of ${APP_FULL_NAME}"
output_text "can only be accessed via the following URL:"
output_null
output_text "https://${TRAEFIK_ADMURL}/"
output_null
output_text "Enjoy using your ${APP_FULL_NAME} installation :)"
output_null
output_text "$0 is exiting now ..."
output_null
read -n 1 -s -r -p $'\033[1;38;5;244mPlease press any key to return to Main Screen ...\033[0m'
echo ""
exit 0

# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# DOCUMENTATION AND USAGE INSTRUCTIONS


: <<'INFO'
Following Code is an example on how to add a container to traefik:
Simply add this code to an existinc compose file (like excalidraw)

labels:
  - "traefik.enable=true"

  # HTTP
  - "traefik.http.routers.excalidraw.rule=Host(`excalidraw.localhost`)"
  - "traefik.http.routers.excalidraw.entrypoints=WEB"

  # Service
  - "traefik.http.services.excalidraw.loadbalancer.server.port=80"

  # HTTPS
  - "traefik.http.routers.excalidraw-secure.rule=Host(`excalidraw.localhost`)"
  - "traefik.http.routers.excalidraw-secure.entrypoints=WEBSECURE"
  - "traefik.http.routers.excalidraw-secure.tls=true"
INFO
