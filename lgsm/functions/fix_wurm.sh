#!/bin/bash
# LinuxGSM fix_wurm.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with Wurm Unlimited.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ ! -f "${serverfiles}/nativelibs/steamclient.so" ]; then
	fixname="steamclient.so x64"
	fn_fix_msg_start
	mkdir -p "${serverfiles}/nativelibs"
	if [ -f "${HOME}/.steam/steamcmd/linux64/steamclient.so" ]; then
		cp "${HOME}/.steam/steamcmd/linux64/steamclient.so" "${serverfiles}/nativelibs/steamclient.so"
	elif [ -f "${steamcmddir}/linux64/steamclient.so" ]; then
		cp "${steamcmddir}/linux64/steamclient.so" "${serverfiles}/nativelibs/steamclient.so"
	fi
	fn_fix_msg_end
fi

# First run requires start with no parms.
# After first run new dirs are created.
if [ ! -d "${serverfiles}/Creative" ]; then
	parmsbypass=1
	fixbypass=1
	exitbypass=1
	command_start.sh
	fn_firstcommand_reset
	sleep 10
	exitbypass=1
	command_stop.sh
	fn_firstcommand_reset
	unset parmsbypass
fi
