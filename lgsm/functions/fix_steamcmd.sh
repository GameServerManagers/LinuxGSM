#!/bin/bash
# LinuxGSM fix_steamcmd.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues related to SteamCMD.


function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Helps fix: [S_API FAIL] SteamAPI_Init() failed; unable to locate a running instance of Steam,or a local steamclient.so.
if [ ! -f "${HOME}/.steam/sdk64/steamclient.so" ]; then
	fixname="steamclient.so sdk64"
	fn_fix_msg_start
	mkdir -pv "${HOME}/.steam/sdk64" >> "${lgsmlog}"
	if [ -f "${HOME}/.steam/steamcmd/linux64/steamclient.so" ]; then
		cp -v "${HOME}/.steam/steamcmd/linux64/steamclient.so" "${HOME}/.steam/sdk64/steamclient.so" >> "${lgsmlog}"
	elif [ -f "${steamcmddir}/linux64/steamclient.so" ]; then
		cp -v "${steamcmddir}/linux64/steamclient.so" "${HOME}/.steam/sdk64/steamclient.so" >> "${lgsmlog}"
	else
		$?=2
	fi
	fn_fix_msg_end
fi

# Helps fix: [S_API FAIL] SteamAPI_Init() failed; unable to locate a running instance of Steam,or a local steamclient.so.
if [ ! -f "${HOME}/.steam/sdk32/steamclient.so" ]; then
	fixname="steamclient.so sdk32"
	fn_fix_msg_start
	mkdir -pv "${HOME}/.steam/sdk32" >> "${lgsmlog}"
	if [ -f "${HOME}/.steam/steamcmd/linux32/steamclient.so" ]; then
		cp -v "${HOME}/.steam/steamcmd/linux32/steamclient.so" "${HOME}/.steam/sdk32/steamclient.so" >> "${lgsmlog}"
	elif [ -f "${steamcmddir}/linux32/steamclient.so" ]; then
		cp -v "${steamcmddir}/linux32/steamclient.so" "${HOME}/.steam/sdk32/steamclient.so" >> "${lgsmlog}"
	else
		$?=2
	fi
	fn_fix_msg_end
fi
