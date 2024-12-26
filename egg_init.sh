#!/bin/bash
# steamcmd Base Installation Script
#
# Server Files: /mnt/server
## just in case someone removed the defaults.
if [ "${STEAM_USER}" == "" ]; then
STEAM_USER=anonymous
STEAM_PASS=""
STEAM_AUTH=""
fi
## download and install steamcmd
cd /tmp
mkdir -p /mnt/server/steamcmd
curl -sSL -o steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzvf steamcmd.tar.gz -C /mnt/server/steamcmd
mkdir -p /mnt/server/steamapps # Fix steamcmd disk write error when this folder is missing
cd /mnt/server/steamcmd
# SteamCMD fails otherwise for some reason, even running as root.
# This is changed at the end of the install process anyways.
chown -R root:root /mnt
export HOME=/mnt/server
## install game using steamcmd
./steamcmd.sh +force_install_dir /mnt/server +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} +app_update ${SRCDS_APPID} ${EXTRA_FLAGS} +quit ## other flags may be needed depending on install. looking at you cs 1.6
## set up 32 bit libraries
mkdir -p /mnt/server/.steam/sdk32
cp -v linux32/steamclient.so ../.steam/sdk32/steamclient.so
## set up 64 bit libraries
mkdir -p /mnt/server/.steam/sdk64
cp -v linux64/steamclient.so ../.steam/sdk64/steamclient.so

#!/bin/bash
# steamcmd Base Installation Script
#
# Server Files: /mnt/server
## just in case someone removed the defaults.
if [ "${STEAM_USER}" == "" ]; then
STEAM_USER=anonymous
STEAM_PASS=""
STEAM_AUTH=""
fi
## download and install steamcmd
cd /tmp
mkdir -p /mnt/server/steamcmd
curl -sSL -o steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzvf steamcmd.tar.gz -C /mnt/server/steamcmd
mkdir -p /mnt/server/steamapps # Fix steamcmd disk write error when this folder is missing
cd /mnt/server/steamcmd
# SteamCMD fails otherwise for some reason, even running as root.
# This is changed at the end of the install process anyways.
chown -R root:root /mnt
export HOME=/mnt/server
## install game using steamcmd
./steamcmd.sh +force_install_dir /mnt/server +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} +app_update ${SRCDS_APPID} ${EXTRA_FLAGS} +quit ## other flags may be needed depending on install. looking at you cs 1.6
## set up 32 bit libraries
mkdir -p /mnt/server/.steam/sdk32
cp -v linux32/steamclient.so ../.steam/sdk32/steamclient.so
## set up 64 bit libraries
mkdir -p /mnt/server/.steam/sdk64
cp -v linux64/steamclient.so ../.steam/sdk64/steamclient.so

# Custom Setup Below
# Install unzip
apt-get install unzip
# Function to print error and exit
error_exit() {
    echo "[ERROR] $1" >&2
    exit 1
}

# Function to download and extract Metamod and CounterStrikeSharp
install_metamod() {
    echo "[INFO] Installing Metamod..."
    wget -nv "${VERSION_METAMOD}" || error_exit "Failed to download Metamod."
    tar -xf "$(basename ${VERSION_METAMOD})" || error_exit "Failed to extract Metamod."
    rm -f "$(basename ${VERSION_METAMOD})"
}

# Function to download and extract CounterStrikeSharp
install_counterstrikesharp() {
    echo "[INFO] Installing CounterStrikeSharp..."
    wget -nv "${VERSION_CSSHARP}" || error_exit "Failed to download CounterStrikeSharp."
    unzip -o -q "$(basename ${VERSION_CSSHARP})" || error_exit "Failed to extract CounterStrikeSharp."
    rm -f "$(basename ${VERSION_CSSHARP})"
}

# Function to download and extract MatchZy
install_matchzy() {
    echo "[INFO] Installing MatchZy..."
    wget -nv "${VERSION_MATCHZY}" || error_exit "Failed to download MatchZy."
    unzip -o -q "$(basename ${VERSION_MATCHZY})" || error_exit "Failed to extract MatchZy."
    rm -f "$(basename ${VERSION_MATCHZY})"
}

if [ "${VERSION_METAMOD}" != "0" ]; then
   install_metamod;
   cp -r addons "/mnt/server/game/csgo/" || error_exit "Failed to copy addons to target."
fi
if [ "${VERSION_CSSHARP}" != "0" ]; then
   install_counterstrikesharp;
   cp -r addons "/mnt/server/game/csgo/" || error_exit "Failed to copy addons to target."
fi
if [ "${VERSION_MATCHZY}" != "0" ]; then
   install_matchzy;
   cp -r addons "/mnt/server/game/csgo/" || error_exit "Failed to copy addons to target."
   cp -r cfg "/mnt/server/game/csgo/" || error_exit "Failed to copy cfg to target."
fi
if [ "${EVERYONE_IS_ADMIN}" -eq "1"]; then
   sed -i  "s/matchzy_everyone_is_admin false/matchzy_everyone_is_admin true/g" "csgo/cfg/MatchZy/config.cfg"
fi
