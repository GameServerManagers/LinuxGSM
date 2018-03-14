#!/bin/bash
# LinuxGSM install_factorio_save.sh function
# Author: Kristian Polso
# Website: https://linuxgsm.com
# Description: Creates the initial save file for Factorio

local commandname="INSTALL"
local commandaction="Install"

echo ""
echo "Creating initial Factorio savefile"
echo "================================="
sleep 1
check_glibc.sh
"${executabledir}"/factorio --create ${serverfiles}/save1
