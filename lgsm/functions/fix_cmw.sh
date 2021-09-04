#!/bin/bash
# LinuxGSM fix_cmw.sh function
# Author: Christian Birk
# Website: https://linuxgsm.com
# Description: Resolves the issue of the not starting server on linux

if [ ! -f "${executabledir}/steam_appid.txt" ]; then
	fixname="steam_appid.txt"
	fn_fix_msg_start
	echo 219640 > "${executabledir}/steam_appid.txt"
	fn_fix_msg_end
fi

if [ ! -f "${servercfgfullpath}" ]; then
	fn_fix_msg_start
	fixname="copy config"
	mkdir "${servercfgdir}"
	cp "${systemdir}/UDKGame/Config/"*.ini "${servercfgdir}"
	fn_fix_msg_end
fi
