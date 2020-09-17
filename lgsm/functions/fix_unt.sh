#!/bin/bash
# LinuxGSM fix_rust.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves startup issue with Unturned.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}:${serverfiles}/Unturned_Headless_Data/Plugins/x86_64"

# steamclient.so x86_64 fix.
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
