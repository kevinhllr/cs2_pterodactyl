#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Constants for URLs
VERSION_METAMOD="https://mms.alliedmods.net/mmsdrop/2.0/mmsource-2.0.0-git1315-linux.tar.gz"
VERSION_CSSHARP="https://github.com/roflmuffin/CounterStrikeSharp/releases/download/v296/counterstrikesharp-with-runtime-build-296-linux-9b4ee72.zip"

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

# Function to download and extract Metamod
install_metamod() {
    echo "[INFO] Installing Metamod..."
    wget -nv "$VERSION_METAMOD" || error_exit "Failed to download Metamod."
    tar -xf "$(basename $VERSION_METAMOD)" || error_exit "Failed to extract Metamod."
    rm -f "$(basename $VERSION_METAMOD)"
}

# Function to download and extract CounterStrikeSharp
install_counterstrikesharp() {
    echo "[INFO] Installing CounterStrikeSharp..."
    wget -nv "$VERSION_CSSHARP" || error_exit "Failed to download CounterStrikeSharp."
    unzip -o -q "$(basename $VERSION_CSSHARP)" || error_exit "Failed to extract CounterStrikeSharp."
    rm -f "$(basename $VERSION_CSSHARP)"
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

    install_metamod
    install_counterstrikesharp

    echo "[INFO] Copying addons to target..."
    cp -r addons "$TARGET/" || error_exit "Failed to copy addons to target."

    cd "$CUR_DIR"
    cleanup

    echo "[INFO] Set Ownership to pterodactyl."
    reown
    echo "[INFO] Installation completed successfully."
}

main "$@"
