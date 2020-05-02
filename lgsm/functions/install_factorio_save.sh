#!/bin/bash
# LinuxGSM install_factorio_save.sh function
# Author: Kristian Polso
# Website: https://linuxgsm.com
# Description: Creates the initial save file for Factorio

modulegroup="INSTALL"
function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo -e ""
echo -e "${lightyellow}Creating initial Factorio savefile${default}"
echo -e "================================="
fn_sleep_time
check_glibc.sh
"${executabledir}"/factorio --create "${serverfiles}/save1"
