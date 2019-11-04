#!/bin/bash
# LinuxGSM install_ut2k4_key.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Activates ut2k4 server with given key.

local commandname="INSTALL"
local commandaction="Install"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo -e ""
echo -e "${lightyellow}Enter ${gamename} CD Key${default}"
echo -e "================================="
fn_sleep_time
echo -e "To get your server listed on the Master Server list"
echo -e "you must get a free CD key. Get a key here:"
echo -e "https://www.epicgames.com/unrealtournament/forums/cdkey.php?2004"
echo -e ""
if [ -z "${autoinstall}" ]; then
	echo -e "Once you have the key enter it below"
	echo -n "KEY: "
	read -r CODE
	echo -e ""\""CDKey"\""="\""${CODE}"\""" > "${systemdir}/cdkey"
	if [ -f "${systemdir}/cdkey" ]; then
		fn_script_log_info "UT2K4 Server CD Key created"
	fi
else
	echo -e "You can add your key using the following command"
	echo -e "./${selfname} server-cd-key"
fi
echo -e ""
