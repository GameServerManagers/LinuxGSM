#!/bin/bash
# LinuxGSM fix_av.sh function
# Author: Christian Birk
# Website: https://linuxgsm.com
# Description: Resolves startup issue with Avorion

local commandname="FIX"
local commandaction="Fix"

if [ ! -d "${serverfiles}/bin/data" ]; then
	fixname="symlink data dir"
	fn_fix_msg_start
	ln -s "${serverfiles}/data" "${serverfiles}/bin/data"
	fn_fix_msg_end
fi

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}:${serverfiles}/linux64"
