#!/bin/bash
# LinuxGSM fix_cmw.sh function
# Author: Christian Birk
# Website: https://linuxgsm.com
# Description: Resolves the issue of the not starting server on linux

fixname="steam_appid.txt"

if [ ! -f "${executabledir}/steam_appid.txt" ]; then
	fn_fix_msg_start
	echo 219640 > "${executabledir}/steam_appid.txt"
	fn_fix_msg_end
fi


if [ ! -f "${executabledir}/lib/steamclient.so" ]; then
	fixname="steamclient.so"
	fn_fix_msg_start
	if [ -f "${HOME}/.steam/steamcmd/linux32/steamclient.so" ]; then
		cp "${HOME}/.steam/steamcmd/linux32/steamclient.so" "${executabledir}/lib/steamclient.so"
	elif [ -f "${steamcmddir}/linux32/steamclient.so" ]; then
		cp "${steamcmddir}/linux32/steamclient.so" "${executabledir}/lib/steamclient.so"
	fi
	fn_fix_msg_end
fi
