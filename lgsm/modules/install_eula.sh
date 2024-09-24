#!/bin/bash
# LinuxGSM install_eula.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Gets user to accept the EULA.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ "${shortname}" == "ts3" ]; then
	eulaurl="https://www.teamspeak.com/en/privacy-and-terms"
elif [ "${shortname}" == "mc" ] || [ "${shortname}" == "pmc" ]; then
	eulaurl="https://account.mojang.com/documents/minecraft_eula"
elif [ "${shortname}" == "ut" ]; then
	eulaurl="https://www.epicgames.com/unrealtournament/unreal-tournament-pre-alpha-test-development-build-eula"
fi

echo -e ""
echo -e "${bold}${lightyellow}Accept ${gamename} EULA${default}"
fn_messages_separator
echo -e "You are required to accept the EULA:"
echo -e "${eulaurl}"
echo -e ""
if [ -z "${autoinstall}" ]; then
	echo -e "By continuing you are indicating your agreement to the EULA."
	echo -e ""
	if ! fn_prompt_yn "Continue?" Y; then
		exitcode=0
		core_exit.sh
	fi
elif [ "${commandname}" == "START" ]; then
	fn_print_info "By continuing you are indicating your agreement to the EULA."
	fn_sleep_time_5
else
	echo -e "By using auto-install you are indicating your agreement to the EULA."
	fn_sleep_time_5
fi

if [ "${shortname}" == "ts3" ]; then
	touch "${executabledir}/.ts3server_license_accepted"
elif [ "${shortname}" == "mc" ] || [ "${shortname}" == "pmc" ]; then
	touch "${serverfiles}/eula.txt"
	echo -e "eula=true" > "${serverfiles}/eula.txt"
elif [ "${shortname}" == "ut" ]; then
	:
fi
