#!/usr/bin/env bash
# LinuxGSM install_header.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Prints installation header.

local commandname="INSTALL"
local commandaction="Install"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

clear
echo "================================="
echo "LinuxGSM - ${gamename}"
echo "by Daniel Gibbs"
echo "Website: https://linuxgsm.com"
echo "Contributors: https://linuxgsm.com/contrib"
echo "Donate: https://linuxgsm.com/donate"
echo "================================="
