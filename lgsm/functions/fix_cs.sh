#!/bin/bash
# LinuxGSM fix_cs.sh function
# Author: Christian Birk
# Website: https://linuxgsm.com
# Description: Resolves various issues with Counter Strike.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# steamclient.so x86 fix.
if [ ! -f "${serverfiles}/steamclient.so" ]; then
	fixname="steamclient.so x86"
	fn_fix_msg_start
	mkdir -p "${serverfiles}"
	if [ -f "${HOME}/.steam/steamcmd/linux32/steamclient.so" ]; then
		cp "${HOME}/.steam/steamcmd/linux32/steamclient.so" "${serverfiles}/steamclient.so"
	elif [ -f "${steamcmddir}/linux32/steamclient.so" ]; then
		cp "${steamcmddir}/linux32/steamclient.so" "${serverfiles}/steamclient.so"
	fi
	fn_fix_msg_end
fi
