#!/bin/bash
# LGSM fix_csgo.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Resolves various issues with CS:GO.

local commandname="FIX"
local commandaction="Fix"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

# Fixes: server not always creating steam_appid.txt file.
if [ ! -f "${filesdir}/steam_appid.txt" ]; then
	fixname="730 steam_appid.txt"
	fn_fix_msg_start
	echo -n "730" >> "${filesdir}/steam_appid.txt"
	fn_fix_msg_end
fi

# Fixes: Error parsing BotProfile.db - unknown attribute 'Rank'".
if ! grep -q "//Rank" "${systemdir}/botprofile.db" > /dev/null 2>&1; then
	fixname="botprofile.db"
	fn_fix_msg_start
	sed -i 's/\tRank/\t\/\/Rank/g' "${systemdir}/botprofile.db" > /dev/null 2>&1
	fn_fix_msg_end
fi

# Fixes: Unknown command "cl_bobamt_vert".
if ! grep -q "//exec default" "${servercfgdir}/valve.rc" > /dev/null 2>&1 || ! grep -q "//exec joystick" "${servercfgdir}/valve.rc" > /dev/null 2>&1; then
	fixname="valve.rc"
	fn_fix_msg_start
	sed -i 's/exec default.cfg/\/\/exec default.cfg/g' "${servercfgdir}/valve.rc" > /dev/null 2>&1
	sed -i 's/exec joystick.cfg/\/\/exec joystick.cfg/g' "${servercfgdir}/valve.rc" > /dev/null 2>&1
	fn_fix_msg_end
fi

# Fixes: workshop map issue.
# http://forums.steampowered.com/forums/showthread.php?t=3170366.
if [ -f "${systemdir}/subscribed_collection_ids.txt" ]||[ -f "${systemdir}/subscribed_file_ids.txt" ]||[ -f "${systemdir}/ugc_collection_cache.txt" ]; then
	fixname="workshop map"
	fn_fix_msg_start
	rm -f "${systemdir}/subscribed_collection_ids.txt"
	rm -f "${systemdir}/subscribed_file_ids.txt"
	rm -f "${systemdir}/ugc_collection_cache.txt"
	fn_fix_msg_end
fi