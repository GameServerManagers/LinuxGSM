#!/bin/bash
# LinuxGSM fix_rw.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves startup issue with Rising World

local modulename="FIX"
local commandaction="Fix"

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}:${serverfiles}/linux64"
