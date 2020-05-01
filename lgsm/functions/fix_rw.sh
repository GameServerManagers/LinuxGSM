#!/bin/bash
# LinuxGSM fix_rw.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with Rising World.

local modulegroup="FIX"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}:${serverfiles}/linux64"
