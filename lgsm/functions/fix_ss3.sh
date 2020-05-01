#!/bin/bash
# LinuxGSM fix_ss3.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with Serious Sam 3.

local modulegroup="FIX"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Fixes: https://steamcommunity.com/app/41070/discussions/0/353916981477716386/
if [ ! -f "${serverfiles}/Bin/steamclient.so" ]||[ "$(diff "${HOME}/.steam/steamcmd/linux32/steamclient.so" "${serverfiles}/Bin/steamclient.so" 2>/dev/null)" ]; then
	fixname="steamclient.so"
	fn_fix_msg_start
	cp -f "${HOME}/.steam/steamcmd/linux32/steamclient.so" "${serverfiles}/Bin/steamclient.so"
	fn_fix_msg_end
fi

# Fixes: .steam/bin32/libsteam.so: cannot open shared object file: No such file or directory
if [ ! -f "${HOME}/.steam/bin32/libsteam.so" ]; then
	fixname="libsteam.so"
	fn_fix_msg_start
	mkdir -pv "${HOME}/.steam/bin32" >> "${lgsmlog}"
	cp "${serverfiles}/Bin/libsteam.so" "${HOME}/.steam/bin32/libsteam.so" >> "${lgsmlog}"
	fn_fix_msg_end
fi
