#!/bin/bash
# LinuxGSM install_eula.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Gets user to accept the EULA.

if [ "${shortname}" == "ts3" ]; then
	eulaurl="https://www.teamspeak.com/en/privacy-and-terms"
elif [ "${shortname}" == "mc" ]; then
	eulaurl="https://account.mojang.com/documents/minecraft_eula"
elif [ "${shortname}" == "ut" ]; then
	eulaurl="https://www.epicgames.com/unrealtournament/unreal-tournament-pre-alpha-test-development-build-eula"
fi

echo ""
echo "Accept ${gamename} EULA"
echo "================================="
sleep 0.5
echo "You are required to accept the EULA:"
echo "${eulaurl}"
echo ""
if [ -z "${autoinstall}" ]; then
	echo "By continuing you are indicating your agreement to the EULA."
	echo ""
	if ! fn_prompt_yn "Continue?" Y; then
		core_exit.sh
	fi
elif [ "${function_selfname}" == "command_start.sh" ]; then
	fn_print_info "By continuing you are indicating your agreement to the EULA."
	echo ""
	sleep 5
else
	echo "By using auto-install you are indicating your agreement to the EULA."
	echo ""
	sleep 5
fi

if [ "${shortname}" == "ts3" ]; then
	touch "${executabledir}/.ts3server_license_accepted"
elif [ "${shortname}" == "mc" ]; then
	touch "${serverfiles}/eula.txt"
	echo "eula=true" > "${serverfiles}/eula.txt"
elif [ "${shortname}" == "ut" ]; then
	:
fi
