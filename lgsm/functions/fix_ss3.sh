#!/bin/bash
# LinuxGSM fix_ss3.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with Serious Sam 3.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Fixes: https://steamcommunity.com/app/41070/discussions/0/353916981477716386/
if [ ! -f "${serverfiles}/Bin/steamclient.so" ]||[ "$(diff "${HOME}/.steam/steamcmd/linux32/steamclient.so" "${serverfiles}/Bin/steamclient.so" 2>/dev/null)" ]; then
	fixname="steamclient.so"
	fn_fix_msg_start
	mkdir -p "${serverfiles}/Bin"
	cp -f "${HOME}/.steam/steamcmd/linux32/steamclient.so" "${serverfiles}/Bin/steamclient.so"
	fn_fix_msg_end
fi

# Fixes: .steam/bin32/libsteam.so: cannot open shared object file: No such file or directory
if [ ! -f "${HOME}/.steam/bin32/libsteam.so" ]; then
	fixname="libsteam.so"
	fn_fix_msg_start
	mkdir -p "${HOME}/.steam/bin32"
	cp "${serverfiles}/Bin/libsteam.so" "${HOME}/.steam/bin32/libsteam.so"
	fn_fix_msg_end
fi
