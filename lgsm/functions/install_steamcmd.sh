#!/bin/bash
# LGSM install_steamcmd.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Downloads SteamCMD on install.

local commandnane="INSTALL"
local commandaction="Install"
local selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

echo ""
echo "Installing SteamCMD"
echo "================================="
sleep 1
check_steamcmd.sh
