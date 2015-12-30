#!/bin/bash
# LGSM fix.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="301215"

# Description: Overall function for managing fixes.
# Runs functions that will fix an issue.

if [ ! -z "${appid}" ]; then
	fix_steamcmd.sh
fi

if [ "${gamename}" == "Counter Strike: Global Offensive" ]; then
	startfix=1
	fix_csgo.sh
elif [ "${gamename}" == "Insurgency" ]; then
	fix_ins.sh
elif [ "${gamename}" == "ARMA 3" ]; then
	fix_arma3.sh	
fi

if [ "${function_selfname}" == "command_install.sh" ]; then
	fix_glibc.sh
	echo "Applying ${gamename} Server Fixes"
	echo "================================="
	if [ "${gamename}" == "Killing Floor" ]; then
		fix_kf.sh
	elif [ "${gamename}" == "Red Orchestra: Ostfront 41-45" ]; then
		fix_ro.sh
	elif [ "${gamename}" == "Unreal Tournament 2004" ]; then
		fix_ut2k4.sh
	elif [ "${gamename}" == "Unreal Tournament 99" ]; then
		fix_ut99.sh
	fi
fi
