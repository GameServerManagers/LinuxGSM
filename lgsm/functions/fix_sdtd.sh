#!/bin/bash
# LinuxGSM fix_sdtd.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves startup issue with 7 Days to Die

local modulename="FIX"
local commandaction="Fix"

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}"
