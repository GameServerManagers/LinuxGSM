#!/bin/bash
# LinuxGSM fix_ottd.sh function
# Author: ttocszed00
# Website: https://linuxgsm.com
# Description: copys bundle to top level.

local modulename="FIX"
local commandaction="Fix"

cp -r "${serverfiles}/.openttd/*" "${rootdir}/.openttd"