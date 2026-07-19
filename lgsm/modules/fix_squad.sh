#!/bin/bash
# LinuxGSM fix_squad.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Squad.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# As the server base dir changed for the game, we need to migrate the default config from the old to the new location
oldservercfg="${serverfiles}/Squad/ServerConfig/${servercfg}"
if [ -f "${oldservercfg}" ] && [ -f "${servercfgfullpath}" ]; then
	# diff old and new config - if it is different move the old config over the new one
	if [ "$(diff -c "${oldservercfg}" "${servercfgfullpath}" | wc -l)" -gt 0 ]; then
		fixname="Migrate server config to new Game folder"
		fn_fix_msg_start
		mv -v "${oldservercfg}" "${servercfgfullpath}"
		fn_fix_msg_end
	else
		fixname="remove the same config from old configdir"
		fn_fix_msg_start
		rm -f "${oldservercfg}"
		fn_fix_msg_end

	fi
fi
