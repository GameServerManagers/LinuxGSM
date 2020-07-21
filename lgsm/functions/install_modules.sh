#!/bin/bash
# LinuxGSM install_modules.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Downloads all modules on install

echo -e ""
echo -e "${lightyellow}Downloading LinuxGSM Modules${default}"
echo -e "================================="

fn_fetch_file "https://github.com/GameServerManagers/LinuxGSM/archive/master.tar.gz" "${tmpdir}" "master.tar.gz" "nochmodx" "norun" "noforce" "nomd5"
fn_dl_extract "${tmpdir}" "master.tar.gz" "${tmpdir}"
cp "${tmpdir}/LinuxGSM-master/lgsm/functions"/*.sh "${functionsdir}"
cp "${tmpdir}/LinuxGSM-master/lgsm/functions"/*.py "${functionsdir}"
chmod +x "${functionsdir}"/*
command_update_linuxgsm.sh
fn_firstcommand_reset
