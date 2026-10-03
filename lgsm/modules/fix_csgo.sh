#!/bin/bash
# LinuxGSM fix_csgo.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Counter-Strike: Global Offensive.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Server files are downloaded using App ID 740 (appid), but the App ID written to steam_appid.txt and steam.inf
# (clientappid) decides which client can connect: 4465480 for standalone CS:GO, 730 for the CS2 csgo_legacy branch.
# SteamCMD update/validate can revert these files, so this runs before every start.

# Fixes: server not always creating steam_appid.txt file.
# The server writes steam_appid.txt with a trailing null byte, which is removed before comparing.
if [ -n "${clientappid}" ] && { [ ! -f "${serverfiles}/steam_appid.txt" ] || [ "$(tr -d '\0' < "${serverfiles}/steam_appid.txt")" != "${clientappid}" ]; }; then
	fixname="${clientappid} steam_appid.txt"
	fn_fix_msg_start
	if echo -n "${clientappid}" > "${serverfiles}/steam_appid.txt"; then
		exitcode=0
	else
		exitcode=1
	fi
	fn_fix_msg_end
fi

# Fixes: steam.inf not using the client App ID.
# steam.inf uses CRLF line endings, the whole value is replaced while keeping the line ending.
if [ -n "${clientappid}" ] && [ -f "${systemdir}/steam.inf" ] && grep -q "^appID=" "${systemdir}/steam.inf" && ! grep -qE "^appID=${clientappid}[[:cntrl:]]?$" "${systemdir}/steam.inf"; then
	fixname="${clientappid} steam.inf"
	fn_fix_msg_start
	sed -i "s/^appID=[^[:cntrl:]]*/appID=${clientappid}/" "${systemdir}/steam.inf"
	exitcode=$?
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

# Fixes: Detected engine 11 but could not load: /home/csgo/serverfiles/bin/libgcc_s.so.1: version `GCC_7.0.0' not found (required by /lib/i386-linux-gnu/libstdc++.so.6)
libgccc_so="${serverfiles}/bin/libgcc_s.so.1"
if [ -f "${libgccc_so}" ]; then
	fixname="libgcc_s.so.1 move away"
	fn_fix_msg_start
	mv "${libgccc_so}" "${libgccc_so}.bak"
	fn_fix_msg_end
fi
