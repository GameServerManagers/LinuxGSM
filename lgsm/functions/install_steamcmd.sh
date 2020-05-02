#!/bin/bash
# LinuxGSM install_steamcmd.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Downloads SteamCMD on install.


function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo -e ""
echo -e "${lightyellow}Installing SteamCMD${default}"
echo -e "================================="
fn_sleep_time
check_steamcmd.sh
