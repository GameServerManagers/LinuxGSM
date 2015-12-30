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
fi

# Configuration
echo ""
echo "Applying ${gamename} Server Fixes"
echo "================================="
fix.sh
echo ""
install_logs.sh
install_gsquery.sh
install_config.sh
if [ "${gamename}" == "Counter Strike: Global Offensive" ]; then
	install_gslt.sh
elif [ "${gamename}" == "Teamspeak 3" ]; then
	install_ts3db.sh
elif [ "${gamename}" == "Team Fortress 2" ]; then
	install_gslt.sh
fi
install_complete.sh
