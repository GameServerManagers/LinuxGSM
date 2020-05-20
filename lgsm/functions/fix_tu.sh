#!/bin/bash
# LinuxGSM fix_tu.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with Tower Unite.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ "${shortname}" == "tu" ]; then
	# Fixes: [S_API FAIL] SteamAPI_Init() failed; unable to locate a running instance of Steam, or a local steamclient.so.
	if [ ! -f "${executabledir}/steamclient.so" ]; then
		fixname="steamclient.so"
		fn_fix_msg_start
		cp -v "${serverfiles}/linux64/steamclient.so" "${executabledir}/steamclient.so" >> "${lgsmlog}"
		fn_fix_msg_end
	fi
fi
