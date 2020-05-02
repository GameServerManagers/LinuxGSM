#!/bin/bash
# LinuxGSM fix_ins.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with Insurgency.

local modulegroup="FIX"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Fixes: ./srcds_linux: error while loading shared libraries: libtier0.so: cannot open shared object file: No such file or directory.

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}:${serverfiles}/bin"

# Fixes: issue #529 - gamemode not passed to debug or start.

if [ "${commandname}" == "DEBUG" ]; then
	defaultmap="\"${defaultmap}\""
else
	defaultmap="\\\"${defaultmap}\\\""
fi
