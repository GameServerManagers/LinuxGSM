#!/bin/bash
# LGSM fix.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="291215"

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