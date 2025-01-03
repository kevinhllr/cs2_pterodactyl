#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Constants for URLs
VERSION_MATCHZY="https://github.com/shobhit-pathak/MatchZy/releases/download/0.8.7/MatchZy-0.8.7.zip"

# Function to print error and exit
error_exit() {
    echo "[ERROR] $1" >&2
    exit 1
}

# Function to validate the target path
validate_target() {
    local target_path="$1"

    # Ensure the path is within /var/lib/pterodactyl/volumes and ends with game/csgo
    if [[ "$target_path" != /var/lib/pterodactyl/volumes/*/game/csgo ]]; then
        error_exit "Target path must be within /var/lib/pterodactyl/volumes and end with game/csgo."
    fi

    # Ensure the target path exists
    if [[ ! -d "$target_path" ]]; then
        error_exit "Target path does not exist: $target_path"
    fi
}

# Function to download and extract MatchZy
install_matchzy() {
    echo "[INFO] Installing MatchZy..."
    wget -nv "$VERSION_MATCHZY" || error_exit "Failed to download MatchZy."
    unzip -o -q "$(basename $VERSION_MATCHZY)" || error_exit "Failed to extract MatchZy."
    rm -f "$(basename $VERSION_MATCHZY)"
}

# Function to clean up temporary files
cleanup() {
    echo "[INFO] Cleaning up temporary files..."
    rm -rf "$TMP_DIR"
}

# Reown files to pterodactyl
reown() {
    chown -R pterodactyl: /var/lib/pterodactyl
}
# Main script
main() {
    # Validate arguments
    if [[ $# -ne 1 ]]; then
        error_exit "Usage: $0 <target_path>"
    fi

    TARGET=$(realpath "$1")
    validate_target "$TARGET"

    CUR_DIR="$PWD"
    TMP_DIR="$CUR_DIR/tmp"

    mkdir -p "$TMP_DIR"
    cd "$TMP_DIR"

    install_matchzy

    echo "[INFO] Copying addons to target..."
    cp -r addons "$TARGET/" || error_exit "Failed to copy addons to target."
    cp -r cfg "$TARGET/" || error_exit "Failed to copy addons to target."

    cd "$CUR_DIR"
    cleanup

    echo "[INFO] Set Ownership to pterodactyl."
    reown
    echo "[INFO] Installation completed successfully."
}

main "$@"
