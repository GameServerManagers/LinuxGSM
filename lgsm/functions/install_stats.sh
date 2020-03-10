#!/bin/bash
# LinuxGSM install_stats.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Enabled LinuxGSM Stats.

local commandname="INSTALL"
local commandaction="Install"
local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

echo -e ""
echo -e "${lightyellow}LinuxGSM Stats${default}"
echo -e "================================="
fn_sleep_time
echo -e "Assist LinuxGSM development by sending anonymous stats to developers."
echo -e "More info: https://docs.linuxgsm.com/configuration/linuxgsm-stats"
echo -e "The following info will be sent:"
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
	fn_print_information_nl "auto-install leaves stats off by default. Stats can be enabled in common.cfg"
fi
