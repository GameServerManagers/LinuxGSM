#!/bin/bash
# LinuxGSM install_steamcmd.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Downloads SteamCMD on install.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo -e ""
echo -e "${bold}${lightyellow}Installing Xonotic${default}"
fn_messages_separator
mkdir -p "${serverfiles}/${selfname}/data"
cp "${serverfiles}/server/server.cfg ${serverfiles}/${selfname}/data/server.cfg"
