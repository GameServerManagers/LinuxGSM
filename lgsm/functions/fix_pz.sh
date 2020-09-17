#!/bin/bash
# LinuxGSM fix_pz.sh function
# Author: Christian Birk
# Website: https://linuxgsm.com
# Description: Resolves various issues with Project Zomboid.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# steamclient.so x86 fix.
if [ ! -f "${serverfiles}/linux32/steamclient.so" ]; then
	fixname="steamclient.so x86"
	fn_fix_msg_start
	mkdir -p "${serverfiles}/linux32"
	if [ -f "${HOME}/.steam/steamcmd/linux32/steamclient.so" ]; then
		cp "${HOME}/.steam/steamcmd/linux32/steamclient.so" "${serverfiles}/linux32/steamclient.so"
	elif [ -f "${steamcmddir}/linux32/steamclient.so" ]; then
		cp "${steamcmddir}/linux32/steamclient.so" "${serverfiles}/linux32/steamclient.so"
	fi
	fn_fix_msg_end
fi

# steamclient.so x86_64 fix.
if [ ! -f "${serverfiles}/linux64/steamclient.so" ]; then
	fixname="steamclient.so x86_64"
	fn_fix_msg_start
	mkdir -p "${serverfiles}/linux64"
	if [ -f "${HOME}/.steam/steamcmd/linux64/steamclient.so" ]; then
		cp "${HOME}/.steam/steamcmd/linux64/steamclient.so" "${serverfiles}/linux64/steamclient.so"
	elif [ -f "${steamcmddir}/linux64/steamclient.so" ]; then
		cp "${steamcmddir}/linux64/steamclient.so" "${serverfiles}/linux64/steamclient.so"
	fi
	fn_fix_msg_end
fi
