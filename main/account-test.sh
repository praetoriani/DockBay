#!/usr/bin/env bash
# =============================================================================
# account-test.sh — Test script demonstrating the use of credentials.lib.sh
#
# Shows both calling conventions:
#   • Without a custom prompt  → library default text is used
#   • With a custom prompt     → caller-supplied text is used
# =============================================================================

CurrentScriptLocation="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"         # ← Gets the full path to the current location
source $CurrentScriptLocation/dockbay.lib.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_PATH="${SCRIPT_DIR}/credentials.lib.sh"

# shellcheck source=./credentials.lib.sh
if [[ ! -f "$LIB_PATH" ]]; then
    printf 'ERROR: Required library not found: %s\n' "$LIB_PATH" >&2
    exit 1
fi

source "$LIB_PATH"

# =============================================================================
# Helper: print a masked version of a string (replaces every char with *)
# =============================================================================
_mask() { printf '%0.s*' $(seq 1 ${#1}); }

# =============================================================================
# Demo 1 — Default prompts (no argument passed to the functions)
# =============================================================================
echo ""
echo "=========================================="
echo "  Demo 1: Default prompts"
echo "=========================================="
echo ""

USERNAME=$(GetUsername)
echo ""
PASSWORD=$(GetPassword)

echo ""
echo "  Username : ${USERNAME}"
echo "  Password : $(_mask "$PASSWORD") (length: ${#PASSWORD})"
echo ""

# =============================================================================
# Demo 2 — Custom prompts (caller supplies the prompt text)
# =============================================================================
echo "=========================================="
echo "  Demo 2: Custom prompts"
echo "=========================================="
echo ""

ADMIN_USER=$(GetUsername "Enter the admin username (min. 4 chars):")
echo ""
ADMIN_PASS=$(GetPassword "Enter the admin password (min. 6 chars):")

echo ""
echo "  Admin username : ${ADMIN_USER}"
echo "  Admin password : $(_mask "$ADMIN_PASS") (length: ${#ADMIN_PASS})"
echo ""

# =============================================================================
# Demo 3 — Empty string argument → must fall back to default prompt
# =============================================================================
echo "=========================================="
echo "  Demo 3: Empty argument -> fallback to default"
echo "=========================================="
echo ""

FALLBACK_USER=$(GetUsername "")   # empty string → default prompt expected
echo ""
FALLBACK_PASS=$(GetPassword "")   # empty string → default prompt expected

echo ""
echo "  Username : ${FALLBACK_USER}"
echo "  Password : $(_mask "$FALLBACK_PASS") (length: ${#FALLBACK_PASS})"
echo ""
