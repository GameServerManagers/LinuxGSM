#!/bin/bash
# LinuxGSM fix_rust.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves startup issue with Unturned.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}:${serverfiles}/Unturned_Headless_Data/Plugins/x86_64"

# copy steamclient to server dir to fix the below
if [ ! -f "${serverfiles}/steamclient.so" ]; then
	fixname="steamclient.so x86_64"
	fn_fix_msg_start
	if [ -f "${HOME}/.steam/steamcmd/linux64/steamclient.so" ]; then
		cp "${HOME}/.steam/steamcmd/linux64/steamclient.so" "${serverfiles}/steamclient.so" >> "${lgsmlog}"
	elif [ -f "${steamcmddir}/linux64/steamclient.so" ]; then
		cp "${steamcmddir}/linux64/steamclient.so" "${serverfiles}/steamclient.so" >> "${lgsmlog}"
	fi
	fn_fix_msg_end
fi

