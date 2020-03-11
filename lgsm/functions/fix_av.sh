#!/bin/bash
# LinuxGSM fix_av.sh function
# Author: Christian Birk
# Website: https://linuxgsm.com
# Description: Resolves startup issue with Avorion

local commandname="FIX"
local commandaction="Fix"

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}/linux64"
