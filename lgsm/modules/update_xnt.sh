#!/bin/bash
# LinuxGSM update_xnt module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Install Xonotic Default Config

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo -e ""
echo -e "${bold}${lightyellow}Installing Xonotic${default}"
fn_messages_separator
mkdir -p "${serverfiles}/Xonotic/${selfname}/data"
cp "${serverfiles}/Xonotic/server/server.cfg ${serverfiles}/Xonotic/${selfname}/data/server.cfg"
