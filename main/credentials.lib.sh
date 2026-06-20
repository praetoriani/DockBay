#!/usr/bin/env bash
# =============================================================================
# credentials.lib.sh — Input helper library for interactive shell scripts
# Provides validated user input functions: GetUsername and GetPassword
#
# Usage:
#   source /path/to/credentials.lib.sh
#
#   username=$(GetUsername)
#   username=$(GetUsername "Enter your login name (min. 4 chars):")
#
#   password=$(GetPassword)
#   password=$(GetPassword "Choose a secure password (min. 6 chars):")
#
# IMPORTANT — Subshell / stdout isolation:
#   Both functions are called via command substitution $(), meaning they run
#   in a subshell where stdout is a pipe back to the caller — NOT the terminal.
#   Therefore ALL terminal I/O (prompts, error messages, ANSI cursor codes)
#   is routed exclusively through /dev/tty.  Only the final validated value
#   is written to stdout so the caller receives a clean, uncontaminated string.
# =============================================================================

# --- ANSI codes — all written to /dev/tty, never to stdout ------------------
# ANSI CODES FROM dockbay.lib.sh WILL BE USED !!

# Cursor up one line, then erase that entire line
readonly _LIB_ERASE_LINE='\033[1A\033[2K'

# Seconds the error message stays visible before being erased
readonly _LIB_ERROR_DISPLAY_SECONDS=4

# --- Default prompt texts ----------------------------------------------------
readonly _LIB_DEFAULT_PROMPT_USERNAME="Please enter a Username (min. 4 chars):"
readonly _LIB_DEFAULT_PROMPT_PASSWORD="Please enter a Password (min. 6 chars):"

# =============================================================================
# Internal helpers
# =============================================================================

# -----------------------------------------------------------------------------
# _lib_tty <format> [args…]
#   Writes formatted output directly to /dev/tty.
#   Single entry point for all terminal I/O — keeps every call site concise
#   and guarantees that no ANSI codes ever leak onto stdout.
# -----------------------------------------------------------------------------
_lib_tty() {
    local fmt="$1"; shift
    # shellcheck disable=SC2059
    printf "$fmt" "$@" > /dev/tty
}

# -----------------------------------------------------------------------------
# _lib_show_error <message>
#   Full error-display cycle routed entirely through /dev/tty:
#     1. Erase the prompt line the user just submitted (cursor up + clear).
#     2. Print the error message in red/bold.
#     3. Wait _LIB_ERROR_DISPLAY_SECONDS so the user can read it.
#     4. Erase the error line — the terminal is now clean for the next prompt.
# -----------------------------------------------------------------------------
_lib_show_error() {
    _lib_tty '%b' "${_LIB_ERASE_LINE}"
    _lib_tty "${RED_BOLD} ✗ Error:${NC}${RED_LIGHT} %s${NC}\n" "$1"
    sleep "$_LIB_ERROR_DISPLAY_SECONDS"
    _lib_tty '%b' "${_LIB_ERASE_LINE}"
}

# =============================================================================
# Public functions
# =============================================================================

# -----------------------------------------------------------------------------
# GetUsername [prompt-text]
#   Prompts the user for a username and validates the input in a loop until
#   a valid value is provided.  Writes the validated username to stdout.
#
# Parameters:
#   $1 (optional) — Custom prompt text.
#                   Falls back to _LIB_DEFAULT_PROMPT_USERNAME when omitted
#                   or empty.
#
# Validation rules:
#   • Minimum length : 4 characters
#   • Allowed chars  : a-z  A-Z  0-9  hyphen (-)  underscore (_)
#
# Example:
#   username=$(GetUsername)
#   username=$(GetUsername "Enter your login name (min. 4 chars):")
# -----------------------------------------------------------------------------
GetUsername() {
    # Use the supplied prompt text; fall back to the default when absent/empty
    local prompt_text="${1:-$_LIB_DEFAULT_PROMPT_USERNAME}"
    local prompt="${BLUE_BOLD}${prompt_text}${NC} "
    local input=""

    while true; do
        _lib_tty '%b' "$prompt"
        IFS= read -r input < /dev/tty

        if [[ ${#input} -lt 4 ]]; then
            _lib_show_error "Username must be at least 4 characters long."
            continue
        fi

        if [[ ! "$input" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            _lib_show_error "Username may only contain letters (a-z, A-Z), digits (0-9), hyphens (-), and underscores (_)."
            continue
        fi

        # Validation passed — write the clean value to stdout only
        printf '%s' "$input"
        return 0
    done
}

# -----------------------------------------------------------------------------
# GetPassword [prompt-text]
#   Prompts the user for a password (input hidden) and validates the input
#   in a loop until a valid value is provided.  Writes the validated password
#   to stdout.
#
# Parameters:
#   $1 (optional) — Custom prompt text.
#                   Falls back to _LIB_DEFAULT_PROMPT_PASSWORD when omitted
#                   or empty.
#
# Validation rules:
#   • Minimum length : 6 characters
#   • Allowed chars  : a-z  A-Z  0-9  + - ? ! * % § .
#
# Note:
#   'read -s' suppresses terminal echo so the password stays invisible.
#   A newline is written to /dev/tty after the hidden input to advance the
#   cursor — this is the line that _lib_show_error will erase on failure.
#
# Example:
#   password=$(GetPassword)
#   password=$(GetPassword "Choose a secure password (min. 6 chars):")
# -----------------------------------------------------------------------------
GetPassword() {
    # Use the supplied prompt text; fall back to the default when absent/empty
    local prompt_text="${1:-$_LIB_DEFAULT_PROMPT_PASSWORD}"
    local prompt="${BLUE_BOLD}${prompt_text}${NC} "
    local input=""

    while true; do
        _lib_tty '%b' "$prompt"
        IFS= read -rs input < /dev/tty
        # Advance the cursor to the next line after the hidden input
        _lib_tty '\n'

        if [[ ${#input} -lt 6 ]]; then
            _lib_show_error "Password must be at least 6 characters long."
            continue
        fi

        # Hyphen placed first in the bracket expression → treated as literal
        if [[ ! "$input" =~ ^[-a-zA-Z0-9+?!*%§#.]+$ ]]; then
            _lib_show_error "Password may only contain letters, digits, and the special characters: + - ? ! * % § # ."
            continue
        fi

        # Validation passed — write the clean value to stdout only
        printf '%s' "$input"
        return 0
    done
}
