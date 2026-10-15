#!/bin/bash
# LinuxGSM fix_cmw.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Chivalry: Medieval Warfare.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ ! -f "${executabledir}/steam_appid.txt" ]; then
	fixname="steam_appid.txt"
	fn_fix_msg_start
	echo 219640 > "${executabledir}/steam_appid.txt"
	fn_fix_msg_end
fi

if [ ! -f "${servercfgfullpath}" ]; then
	fn_fix_msg_start
	fixname="copy config"
	if [ ! -d "${servercfgdir}" ]; then
		mkdir -p "${servercfgdir}"
	fi
	cp "${systemdir}/UDKGame/Config/"*.ini "${servercfgdir}"
	fn_fix_msg_end
fi
