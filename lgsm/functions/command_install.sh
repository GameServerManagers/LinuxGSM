#!/bin/bash
# LGSM command_install.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Overall function for the installer.

local commandname="INSTALL"
local commandaction="Install"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
install_header.sh
install_server_dir.sh
install_logs.sh
check_deps.sh
# Download and install
if [ "${gamename}" == "Unreal Tournament 2004" ]; then
	install_server_files.sh
	install_ut2k4_key.sh
elif [ "${gamename}" == "Unreal Tournament 3" ]||[ "${gamename}" == "Battlefield: 1942" ]||[ "${gamename}" == "Enemy Territory" ]||[ "${gamename}" == "Unreal Tournament 99" ]||[ "${gamename}" == "Unreal Tournament" ]||[ "${gamename}" == "TeamSpeak 3" ]||[ "${gamename}" == "Minecraft" ]||[ "${gamename}" == "Mumble" ]; then
	installer=1
	install_server_files.sh
elif [ -n "${appid}" ]; then
	install_steamcmd.sh
	install_server_files.sh
fi

# Configuration
install_config.sh
if [ "${gamename}" == "Counter-Strike: Global Offensive" ]||[ "${gamename}" == "Team Fortress 2" ]||[ "${gamename}" == "BrainBread 2" ]; then
	install_gslt.sh
elif [ "${gamename}" == "TeamSpeak 3" ]; then
	install_ts3db.sh
fi

fix.sh
install_complete.sh
core_exit.sh
