#!/usr/bin/env bash
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
# Test Results:    ✓ Verified working
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆
# Script Name:   dockbay-prechecks.sh
# Last Update:   14.06.2026
# Written by:    Praetoriani
# Website:       https://github.com/praetoriani
# ⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆

# Load the WSL2 Library (important for this script)
#source ./dockbay.lib.sh

PerformDockBayPrechecks() {
    # --------------------------------------------------
    # STEP 01: CHECK INSTALLED PACKAGES
    # --------------------------------------------------
    for pkg in "${REQUIRED_PKGS[@]}"; do
        WriteLogfile "${SETUPLOG}" "→ Checking for installed package:  $pkg"
        CheckPackage "$pkg"
        output_null
    done
    if [ ${#REQUIRED_PKGS[@]} -eq 0 ]; then
        # set  setup.systemtools  to  false
        jq '.setup.systemtools = false' $SETUPCFGJSON > $SETUPTMPJSON && mv $SETUPTMPJSON $SETUPCFGJSON
    fi
    WriteLogfile "${SETUPLOG}" "→ Required Packages to be installed:  $([ ${#REQUIRED_PKGS[@]} -eq 0 ] && echo 0 || printf "%s, " "${REQUIRED_PKGS[@]}")"
    ShowRequiredPKG
    output_null

    # --------------------------------------------------
    # STEP 02: CHECK DOCKER COMPONENTS
    # --------------------------------------------------
    WriteLogfile "${SETUPLOG}" "→ Performing Docker System Check ..."
    # Running System Prechecks from wsl2-lib.sh
    for pkg in "${DOCKER_PKGS[@]}"; do
        WriteLogfile "${SETUPLOG}" "→ Checking for installed package:  Docker $pkg"
        CheckDocker "$pkg"
        output_null
    done
    if [ ${#DOCKER_PKGS[@]} -eq 0 ]; then
        # set  setup.dockertools  to  false
        jq '.setup.dockertools = false' $SETUPCFGJSON > $SETUPTMPJSON && mv $SETUPTMPJSON $SETUPCFGJSON
    fi
    WriteLogfile "${SETUPLOG}" "→ Required Docker Packages to be installed:  $([ ${#DOCKER_PKGS[@]} -eq 0 ] && echo 0 || printf "%s, " "${DOCKER_PKGS[@]}")"
    if [ ${#DOCKER_PKGS[@]} -eq 0 ]; then
        output_text "Reuired Docker Packages to be installed on your system:  0"
    else
        output_text "Reuired Docker Packages to be installed on your system:"
        for pkg in "${DOCKER_PKGS[@]}"; do
            output_text "${RED_BOLD}→  $pkg ${DARK_GRAY_BOLD}"
        done
    fi
    output_null

    # --------------------------------------------------
    # STEP 03: CHECK DB CLUSTER
    # --------------------------------------------------
    WriteLogfile "${SETUPLOG}" "→ Checking if DB-Cluster exists ..."
    # Running System Prechecks from wsl2-lib.sh
    for pkg in "${DBCLUSTER_PKG[@]}"; do
        WriteLogfile "${SETUPLOG}" "→ Checking for Docker Container:  $pkg"
        CheckDBCluster $pkg
        output_null
    done
    WriteLogfile "${SETUPLOG}" "→ Required Docker Packages to be installed:  $([ ${#DBCLUSTER_PKG[@]} -eq 0 ] && echo 0 || printf "%s, " "${DBCLUSTER_PKG[@]}")"
    if [ ${#DBCLUSTER_PKG[@]} -eq 0 ]; then
        output_text "Reuired Docker Packages to be installed on your system:  0"
    else
        output_text "Reuired Docker Packages to be installed on your system:"
        for pkg in "${DBCLUSTER_PKG[@]}"; do
            output_text "${RED_BOLD}→  $pkg ${DARK_GRAY_BOLD}"
        done
    fi
    output_null
    
    # --------------------------------------------------
    # STEP 04: CHECK TRAEFIK PROXY
    # --------------------------------------------------
    WriteLogfile "${SETUPLOG}" "→ Checking if Traefik Proxy exists ..."
    output_text "Checking if  'Traefik Proxy'  is already present ..."
    sleep 0.1
    if [ "$(CheckContainer "Traefik")" = "ok" ]; then
        jq '.setup.traefikproxy = false' $SETUPCFGJSON > $SETUPTMPJSON && mv $SETUPTMPJSON $SETUPCFGJSON
        WriteLogfile "${SETUPLOG}" "→ Traefik Proxy already exists"
        if [ "$(ContainerStatus "Traefik")" = "ok" ]; then
            output_text "${GREEN_BOLD}[ ✓ ]${DARK_GRAY_BOLD}  Container found.     Status:  ${GREEN_BOLD}running${DARK_GRAY_BOLD}"
        else
            output_text "${GREEN_BOLD}[ ✓ ]${DARK_GRAY_BOLD}  Container found.     Status:  ${RED_BOLD}not running${DARK_GRAY_BOLD}"
        fi
    else
        WriteLogfile "${SETUPLOG}" "→ Traefik Proxy not found."
        output_text "${RED_BOLD}[ × ]${DARK_GRAY_BOLD}  Container not found.  Status:  not available"
    fi
    output_null
    sleep 0.1
    
    # Update Precheck-Status Information!
    DOCKBAY_PRECKECKS="true"
    jq '.setup.dockbaychecks = false' $SETUPCFGJSON > $SETUPTMPJSON && mv $SETUPTMPJSON $SETUPCFGJSON
}