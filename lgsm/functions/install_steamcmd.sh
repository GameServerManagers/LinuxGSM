#!/bin/bash
# LinuxGSM install_steamcmd.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Downloads SteamCMD on install.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo -e ""
echo -e "${lightyellow}Installing SteamCMD${default}"
echo -e "================================="
fn_sleep_time
check_steamcmd.sh
