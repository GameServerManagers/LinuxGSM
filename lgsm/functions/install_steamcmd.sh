#!/bin/bash
# LinuxGSM install_steamcmd.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Downloads SteamCMD on install.

local commandname="INSTALL"
local commandaction="Install"

echo ""
echo "${lightyellow}Installing SteamCMD${default}"
echo "================================="
fn_sleep_time
check_steamcmd.sh
