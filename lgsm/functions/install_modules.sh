#!/bin/bash
# LinuxGSM install_modules.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Downloads all modules on install.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo -e ""
echo -e "${lightyellow}Downloading LinuxGSM Modules${default}"
echo -e "================================="

fn_fetch_file "https://github.com/GameServerManagers/LinuxGSM/archive/master.tar.gz" "${tmpdir}" "master.tar.gz" "nochmodx" "norun" "noforce" "nohash"
fn_dl_extract "${tmpdir}" "master.tar.gz" "${tmpdir}"
cp "${tmpdir}/LinuxGSM-master/lgsm/functions"/*.sh "${functionsdir}"
cp "${tmpdir}/LinuxGSM-master/lgsm/functions"/*.py "${functionsdir}"
chmod +x "${functionsdir}"/*
command_update_linuxgsm.sh
fn_firstcommand_reset
