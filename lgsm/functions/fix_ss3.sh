#!/bin/bash
# LinuxGSM fix_ss3.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with Serious Sam 3.

local commandname="FIX"
local commandaction="Fix"
local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

# Fixes https://steamcommunity.com/app/41070/discussions/0/353916981477716386/
if [ "$(diff "${steamcmddir}/linux32/steamclient.so" "${serverfiles}/Bin/steamclient.so" >/dev/null)" ]; then
	fixname="steamclient.so"
	fn_fix_msg_start
	cp -f "${steamcmddir}/linux32/steamclient.so" "${serverfiles}/Bin/steamclient.so"
	fn_fix_msg_end
fi
