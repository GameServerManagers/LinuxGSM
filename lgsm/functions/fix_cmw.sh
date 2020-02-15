#!/bin/bash
# LinuxGSM fix_cmw.sh function
# Author: Christian Birk
# Website: https://linuxgsm.com
# Description: Resolves the issue of the not starting server on linux

local appidfilepath="${executabledir}/steam_appid.txt"
if [ ! -f "${appidfilepath}" ]; then
	echo 219640 > "${appidfilepath}"
fi

if [ ! -f "${executabledir}/lib/steamclient.so" ]; then
	fixname="steamclient.so"
	fn_fix_msg_start
	if [ -f "${HOME}/.steam/steamcmd/linux32/steamclient.so" ]; then
		cp -v "${HOME}/.steam/steamcmd/linux32/steamclient.so" "${executabledir}/lib/steamclient.so"
	elif [ -f "${steamcmddir}/linux32/steamclient.so" ]; then
		cp -v "${steamcmddir}/linux32/steamclient.so" "${executabledir}/lib/steamclient.so"
	else
		fn_print_error "Cannot copy steamclient.so to executeabledir"
	fi
	fn_fix_msg_end
fi
