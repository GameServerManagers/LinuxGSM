#!/bin/bash
# LinuxGSM command_install.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://linuxgsm.com
# Description: Overall function for the installer.

local commandname="INSTALL"
local commandaction="Install"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

check.sh
install_header.sh
install_server_dir.sh
install_logs.sh
check_deps.sh
installflag=1
# Download and install
if [ "${gamename}" == "Unreal Tournament 2004" ]; then
	install_server_files.sh
	install_ut2k4_key.sh
elif [ -z "${appid}" ]; then
	installer=1
	install_server_files.sh
elif [ -n "${appid}" ]; then
	install_steamcmd.sh
	install_server_files.sh
fi

# Configuration
install_config.sh
if [ "${gamename}" == "BrainBread 2" ]||[ "${gamename}" == "Black Mesa: Deathmatch" ]||[ "${gamename}" == "Counter-Strike: Global Offensive" ]||[ "${gamename}" == "Empires Mod" ]||[ "${gamename}" == "Garry’s Mod" ]||[ "${gamename}" == "No more Room in Hell" ]||[ "${gamename}" == "Team Fortress 2" ]||[ "${gamename}" == "Tower Unite" ]; then
	install_gslt.sh
elif [ "${gamename}" == "Don't Starve Together" ]; then
	install_dst_token.sh
elif [ "${gamename}" == "Squad" ]; then
	install_squad_license.sh
elif [ "${gamename}" == "TeamSpeak 3" ]; then
	install_ts3db.sh
elif [ "${gamename}" == "Multi Theft Auto" ]; then
	command_install_resources_mta.sh
fi

fix.sh
install_complete.sh
core_exit.sh
