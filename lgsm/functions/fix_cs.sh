#!/bin/bash
# LinuxGSM fix_cs.sh function
# Author: Christian Birk
# Website: https://linuxgsm.com
# Description: Resolves various issues with Counter Strike.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ "${shortname}" == "cs" ]; then
	# Fixes: steamclient.so: cannot open shared object file: No such file or directory
	if [ ! -f "${serverfiles}/steamclient.so" ]; then
		fixname="steamclient.so x86"
		fn_fix_msg_start
		if [ -f "${HOME}/.steam/steamcmd/linux32/steamclient.so" ]; then
			cp "${steamcmddir}/linux32/steamclient.so" "${serverfiles}/steamclient.so" >> "${lgsmlog}"
		elif [ -f "${steamcmddir}/linux32/steamclient.so" ]; then
			cp "${steamcmddir}/linux32/steamclient.so" "${serverfiles}/steamclient.so" >> "${lgsmlog}"
		else
			:
		fi
		fn_fix_msg_end
	fi
fi
