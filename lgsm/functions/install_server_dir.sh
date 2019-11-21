#!/bin/bash
# LinuxGSM install_server_dir.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Creates the server directory.

local commandname="INSTALL"
local commandaction="Install"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo -e ""
echo -e "${lightyellow}Server Directory${default}"
echo -e "================================="
fn_sleep_time
if [ -d "${serverfiles}" ]; then
	fn_print_warning_nl "A server is already installed here."
fi
pwd
echo -e ""
if [ -z "${autoinstall}" ]; then
	if ! fn_prompt_yn "Continue?" Y; then
		exit
	fi
fi
if [ ! -d "${serverfiles}" ]; then
	mkdir -v "${serverfiles}"
fi
