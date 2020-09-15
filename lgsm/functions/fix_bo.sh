#!/bin/bash
# LinuxGSM fix_hw.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with Ballistic Overkill.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}:${serverfiles}/BODS_Data/Plugins/x86_64:${serverfiles}/BODS_Data/Plugins/x86"

# steamclient.so x86 fix for unity3d game server
if [ ! -f "${serverfiles}/BODS_Data/Plugins/x86/steamclient.so" ]; then
	fixname="steamclient.so x86"
	fn_fix_msg_start
	mkdir -p "${serverfiles}/BODS_Data/Plugins/x86"
	if [ -f "${HOME}/.steam/steamcmd/linux32/steamclient.so" ]; then
		cp "${HOME}/.steam/steamcmd/linux32/steamclient.so" "${serverfiles}/BODS_Data/Plugins/x86/steamclient.so"
	elif [ -f "${steamcmddir}/linux32/steamclient.so" ]; then
		cp "${steamcmddir}/linux32/steamclient.so" "${serverfiles}/BODS_Data/Plugins/x86/steamclient.so"
	fi
	fn_fix_msg_end
fi

# steamclient.so x86_64 fix for unity3d game server
if [ ! -f "${serverfiles}/BODS_Data/Plugins/x86_64/steamclient.so" ]; then
	fixname="steamclient.so x86_64"
	fn_fix_msg_start
	mkdir -p "${serverfiles}/BODS_Data/Plugins/x86_64"
	if [ -f "${HOME}/.steam/steamcmd/linux64/steamclient.so" ]; then
		cp "${HOME}/.steam/steamcmd/linux64/steamclient.so" "${serverfiles}/BODS_Data/Plugins/x86_64/steamclient.so"
	elif [ -f "${steamcmddir}/linux64/steamclient.so" ]; then
		cp "${steamcmddir}/linux64/steamclient.so" "${serverfiles}/BODS_Data/Plugins/x86_64/steamclient.so"
	fi
	fn_fix_msg_end
fi
