#!/bin/bash
# LinuxGSM install_factorio_save.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Creates the initial save file for Factorio.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo -e ""
echo -e "${bold}${lightyellow}Creating initial Factorio savefile${default}"
fn_messages_separator
check_glibc.sh
"${executabledir}"/factorio --create "${serverfiles}/save1"
