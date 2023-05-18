#!/bin/bash
# LinuxGSM fix_cmw.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves the issue of the not starting server on linux

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

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
