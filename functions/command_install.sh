#!/bin/bash
# LGSM fn_install function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
install_header.sh
install_serverdir.sh

# Download and install
if [ "${gamename}" == "Unreal Tournament 2004" ]; then
	install_dl_ut2k4.sh
	install_ut2k4.sh
	install_ut2k4_key.sh
elif [ "${gamename}" == "Unreal Tournament 99" ]; then
	install_dl_ut99.sh
	install_ut99.sh
elif [ "${gamename}" == "Teamspeak 3" ]; then
	install_ts3.sh
elif [ ! -z "${appid}" ]; then
	install_steamcmd.sh
	install_serverfiles.sh
	install_fix_steam.sh
fi

# Configuration
fix_glibc.sh
install_logs.sh
install_gsquery.sh
install_config.sh
if [ "${gamename}" == "Counter Strike: Global Offensive" ]; then
	install_gslt.sh
	fix_csgo.sh
elif [ "${gamename}" == "Teamspeak 3" ]; then
	install_ts3db.sh
elif [ "${gamename}" == "Team Fortress 2" ]; then
	install_gslt.sh
elif [ "${gamename}" == "Killing Floor" ]; then
	install_fix_kf.sh
elif [ "${gamename}" == "Red Orchestra: Ostfront 41-45" ]; then
	install_fix_ro.sh
elif [ "${gamename}" == "Unreal Tournament 2004" ]; then
	install_fix_ut2k4.sh
elif [ "${gamename}" == "Unreal Tournament 99" ]; then
	install_fix_ut99.sh
fi
install_complete.sh
