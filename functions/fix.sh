#!/bin/bash
# LGSM fix.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="020116"

# Description: Overall function for managing fixes.
# Runs functions that will fix an issue.

# Fixes that are run on start
if [ "${function_selfname}" != "command_install.sh" ]; then
	if [ ! -z "${appid}" ]; then
		fix_steamcmd.sh
	fi	

	if [ "${gamename}" == "Counter Strike: Global Offensive" ]; then
		startfix=1
		fix_csgo.sh
	elif [ "${gamename}" == "Don't Starve Together" ]; then
		fix_dst.sh		
	elif [ "${gamename}" == "Insurgency" ]; then
		fix_ins.sh
	elif [ "${gamename}" == "ARMA 3" ]; then
		fix_arma3.sh	
	fi
fi

# Fixes that are run on install only.
if [ "${function_selfname}" == "command_install.sh" ]; then
	fix_glibc.sh
	if [ "${gamename}" == "Killing Floor" ]; then
		echo ""
		echo "Applying ${gamename} Server Fixes"
		echo "================================="
		sleep 1			
		fix_kf.sh
	elif [ "${gamename}" == "Red Orchestra: Ostfront 41-45" ]; then
		echo ""
		echo "Applying ${gamename} Server Fixes"
		echo "================================="
		sleep 1		
		fix_ro.sh
	elif [ "${gamename}" == "Unreal Tournament 2004" ]; then
		echo ""
		echo "Applying ${gamename} Server Fixes"
		echo "================================="
		sleep 1		
		fix_ut2k4.sh
	elif [ "${gamename}" == "Unreal Tournament 99" ]; then
		echo ""
		echo "Applying ${gamename} Server Fixes"
		echo "================================="
		sleep 1		
		fix_ut99.sh
	fi
fi
