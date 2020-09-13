#!/bin/bash
# LinuxGSM fix_tu.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with Tower Unite.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Fixes: [S_API FAIL] SteamAPI_Init() failed; unable to locate a running instance of Steam, or a local steamclient.so.
if [ ! -f "${executabledir}/steamclient.so" ]; then
	fixname="steamclient.so x86_64"
	fn_fix_msg_start
	if [ -f "${HOME}/.steam/steamcmd/linux64/steamclient.so" ]; then
		cp "${HOME}/.steam/steamcmd/linux64/steamclient.so" "${executabledir}/steamclient.so" >> "${lgsmlog}"
	elif [ -f "${steamcmddir}/linux64/steamclient.so" ]; then
		cp "${steamcmddir}/linux64/steamclient.so" "${executabledir}/steamclient.so" >> "${lgsmlog}"
	fi
	fn_fix_msg_end
fi
