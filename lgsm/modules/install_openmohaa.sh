#!/bin/bash
# LinuxGSM install_openmohaa.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Installs OpenMoHAA for the Medal of Honor: Allied Assault OpenMoHAA variants.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo -e ""
echo -e "${bold}${lightyellow}Installing OpenMoHAA${default}"
fn_messages_separator
fn_fetch_file "https://github.com/openmoh/openmohaa/releases/download/v0.82.1/openmohaa-v0.82.1-linux-amd64.zip" "" "" "" "${tmpdir}" "openmohaa-v0.82.1-linux-amd64.zip" "nochmodx" "norun" "noforce" "57692d057a684afb7f7e91a61fcd8c062b29ab1b639f27453830084a88cd653c"
mkdir -p "${serverfiles}/openmohaa"
fn_dl_extract "${tmpdir}" "openmohaa-v0.82.1-linux-amd64.zip" "${serverfiles}/openmohaa"
chmod +x "${serverfiles}/openmohaa/omohaaded"
fn_clear_tmp
