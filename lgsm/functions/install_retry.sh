#!/bin/bash
# LinuxGSM install_retry.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Asks for installation retry after failure.

local commandname="INSTALL"
local commandaction="Install"
function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if fn_prompt_yn "Retry install?" Y; then
	command_install.sh; exit
else
	echo Exiting; exit
fi
