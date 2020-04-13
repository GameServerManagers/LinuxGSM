#!/bin/bash
# LinuxGSM fix_arma3.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves an issue with ARMA3.

local modulename="FIX"
local commandaction="Fix"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Fixes: 20150 Segmentation fault (core dumped) error.
if [ ! -d "${XDG_DATA_HOME:="${HOME}/.local/share"}/Arma 3" ]||[ ! -d "${XDG_DATA_HOME:="${HOME}/.local/share"}/Arma 3 - Other Profiles" ]; then
	fixname="20150 Segmentation fault (core dumped)"
	fn_fix_msg_start
	mkdir -p "${XDG_DATA_HOME:="${HOME}/.local/share"}/Arma 3 - Other Profiles"
	fn_fix_msg_end
fi
