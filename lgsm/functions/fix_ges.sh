#!/bin/bash
# LinuxGSM fix_ges.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with GoldenEye: Source.

local modulename="FIX"
local commandaction="Fix"

# Fixes: MALLOC_CHECK_ needing to be set to 0.
export MALLOC_CHECK_=0
