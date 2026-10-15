#!/bin/bash
# LinuxGSM install_stats.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Enabled LinuxGSM Stats.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo -e ""
echo -e "${bold}${lightyellow}LinuxGSM Stats${default}"
fn_messages_separator
echo -e "Assist LinuxGSM development by sending anonymous stats to developers."
echo -e "Collected data is publicly available: ${italic}https://linuxgsm.com/data/usage${default}"
echo -e "More info: ${italic}https://docs.linuxgsm.com/configuration/linuxgsm-stats${default}"
echo -e ""
echo -e "The following info will be sent: "
echo -e "* game server"
echo -e "* distro"
echo -e "* game server resource usage"
echo -e "* server hardware info"
if [ -z "${autoinstall}" ]; then
	if fn_prompt_yn "Allow anonymous usage statistics?" Y; then
		echo "stats=\"on\"" >> "${configdirserver}/common.cfg"
		fn_print_information_nl "Stats setting is now enabled in common.cfg."
	fi
else
	echo -e ""
	echo -e "auto-install leaves stats off by default. Stats can be enabled in ${italic}common.cfg${default}"
fi
