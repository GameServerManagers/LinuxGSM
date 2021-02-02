#!/bin/bash
# LinuxGSM fix_csgo.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves various issues with CS:GO.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Fixes: server not always creating steam_appid.txt file.
if [ ! -f "${serverfiles}/steam_appid.txt" ]; then
	fixname="730 steam_appid.txt"
	fn_fix_msg_start
	echo -n "730" >> "${serverfiles}/steam_appid.txt"
	fn_fix_msg_end
fi

# Fixes: Error parsing BotProfile.db - unknown attribute 'Rank'".
if [ -f "${systemdir}/botprofile.db" ] && grep "^\s*Rank" "${systemdir}/botprofile.db" > /dev/null 2>&1; then
	fixname="botprofile.db"
	fn_fix_msg_start
	sed -i 's/^\s*Rank/\t\/\/Rank/g' "${systemdir}/botprofile.db" > /dev/null 2>&1
	fn_fix_msg_end
fi

# Fixes: Unknown command "cl_bobamt_vert" and exec: couldn't exec joystick.cfg.
if [ -f "${servercfgdir}/valve.rc" ] && grep -E '^\s*exec\s*(default|joystick)\.cfg' "${servercfgdir}/valve.rc" > /dev/null 2>&1; then
	fixname="valve.rc"
	fn_fix_msg_start
	sed -i 's/^\s*exec\s*default.cfg/\/\/exec default.cfg/g' "${servercfgdir}/valve.rc" > /dev/null 2>&1
	sed -i 's/^\s*exec\s*joystick.cfg/\/\/exec joystick.cfg/g' "${servercfgdir}/valve.rc" > /dev/null 2>&1
	fn_fix_msg_end
fi
