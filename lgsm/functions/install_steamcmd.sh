#!/bin/bash
# LGSM install_steamcmd.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Downloads SteamCMD on install.

local modulename="Install"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

echo ""
echo "Installing SteamCMD"
echo "================================="
sleep 1
check_steamcmd.sh
