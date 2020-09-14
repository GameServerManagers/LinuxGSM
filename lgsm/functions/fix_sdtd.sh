#!/bin/bash
# LinuxGSM fix_sdtd.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with 7 Days to Die.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}"

# Fixes: [S_API FAIL] SteamAPI_Init() failed; unable to locate a running instance of Steam, or a local steamclient.so.
if [ ! -f "${serverfiles}/steamclient.so" ]; then
	fixname="steamclient.so x86_64"
	fn_fix_msg_start
	mkdir -p "${serverfiles}"
	if [ -f "${HOME}/.steam/steamcmd/linux64/steamclient.so" ]; then
		cp "${HOME}/.steam/steamcmd/linux64/steamclient.so" "${serverfiles}/steamclient.so"
	elif [ -f "${steamcmddir}/linux64/steamclient.so" ]; then
		cp "${steamcmddir}/linux64/steamclient.so" "${serverfiles}/steamclient.so"
	fi
	fn_fix_msg_end
fi
