#!/bin/bash
# LinuxGSM install_ut2k4_key.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Activates ut2k4 server with given key.

commandname="INSTALL"
commandaction="Install"
function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo ""
echo "Enter ${gamename} CD Key"
echo "================================="
sleep 0.5
echo "To get your server listed on the Master Server list"
echo "you must get a free CD key. Get a key here:"
echo "https://forums.unrealtournament.com/utserver/cdkey.php?2004"
echo ""
if [ -z "${autoinstall}" ]; then
	echo "Once you have the key enter it below"
	echo -n "KEY: "
	read -r CODE
	echo ""\""CDKey"\""="\""${CODE}"\""" > "${systemdir}/cdkey"
	if [ -f "${systemdir}/cdkey" ]; then
		fn_script_log_info "UT2K4 Server CD Key created"
	fi
else
	echo "You can add your key using the following command"
	echo "./${selfname} server-cd-key"
fi
echo ""