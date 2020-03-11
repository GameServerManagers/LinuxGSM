#!/bin/bash
# LinuxGSM fix_ins.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with Insurgency.

local modulename="FIX"
local commandaction="Fix"

# Fixes: ./srcds_linux: error while loading shared libraries: libtier0.so: cannot open shared object file: No such file or directory.

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}:${serverfiles}/bin"

# Fixes: issue #529 - gamemode not passed to debug or start.

if [ "${function_selfname}" == "command_debug.sh" ]; then
	defaultmap="\"${defaultmap}\""
else
	defaultmap="\\\"${defaultmap}\\\""
fi
