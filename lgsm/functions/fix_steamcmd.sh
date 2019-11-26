#!/bin/bash
# LinuxGSM fix_steamcmd.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues related to SteamCMD.

local commandname="FIX"
local commandaction="Fix"
local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

# Fixes: [S_API FAIL] SteamAPI_Init() failed; unable to locate a running instance of Steam,or a local steamclient.so.
if [ ! -f "${HOME}/.steam/sdk32/steamclient.so" ]; then
	fixname="steamclient.so"
	fn_fix_msg_start
	mkdir -pv "${HOME}/.steam/sdk32" >> "${lgsmlog}"
	cp -v "${steamcmddir}/linux32/steamclient.so" "${HOME}/.steam/sdk32/steamclient.so" >> "${lgsmlog}"
	fn_fix_msg_end
fi

if [ "${shortname}" == "bt" ]; then
	# Fixes: [S_API FAIL] SteamAPI_Init() failed; SteamAPI_IsSteamRunning() failed.
	if [ ! -L "${executabledir}/lib64/steamclient.so" ]; then
		fixname="steamclient.so x86_64"
		fn_fix_msg_start
		cp -s -v "${steamcmddir}/linux64/steamclient.so" "${executabledir}/lib64/steamclient.so" >> "${lgsmlog}"
		fn_fix_msg_end
	fi
elif [ "${shortname}" == "ss3" ]; then
	# Fixes: .steam/bin32/libsteam.so: cannot open shared object file: No such file or directory
	if [ ! -f "${HOME}/.steam/bin32/libsteam.so" ]; then
		fixname="libsteam.so"
		fn_fix_msg_start
		mkdir -pv "${HOME}/.steam/bin32" >> "${lgsmlog}"
		cp "${serverfiles}/Bin/libsteam.so" "${HOME}/.steam/bin32/libsteam.so" >> "${lgsmlog}"
		fn_fix_msg_end
	fi
elif [ "${shortname}" == "hw" ]; then
	# Fixes: [S_API FAIL] SteamAPI_Init() failed; unable to locate a running instance of Steam, or a local steamclient.so.
	if [ ! -f "${serverfiles}/Hurtworld_Data/Plugins/x86/steamclient.so" ]; then
		fixname="steamclient.so x86"
		fn_fix_msg_start
		cp "${steamcmddir}/linux32/steamclient.so" "${serverfiles}/Hurtworld_Data/Plugins/x86/steamclient.so" >> "${lgsmlog}"
		fn_fix_msg_end
	fi
	if [ ! -f "${serverfiles}/Hurtworld_Data/Plugins/x86_64/steamclient.so" ]; then
		fixname="steamclient.so x86_64"
		fn_fix_msg_start
		cp "${steamcmddir}/linux32/steamclient.so" "${serverfiles}/Hurtworld_Data/Plugins/x86_64/steamclient.so" >> "${lgsmlog}"
		fn_fix_msg_end
	fi
elif [ "${shortname}" == "tu" ]; then
	# Fixes: [S_API FAIL] SteamAPI_Init() failed; unable to locate a running instance of Steam, or a local steamclient.so.
	if [ ! -f "${executabledir}/steamclient.so" ]; then
		fixname="steamclient.so"
		fn_fix_msg_start
		cp -v "${serverfiles}/linux64/steamclient.so" "${executabledir}/steamclient.so" >> "${lgsmlog}"
		fn_fix_msg_end
	fi
fi
