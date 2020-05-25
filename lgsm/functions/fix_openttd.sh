#!/bin/bash
# LinuxGSM fix_ottd.sh function
# Author: ttocszed00
# Website: https://linuxgsm.com
# Description: copis OpenGFX to baset directory.

local modulename="FIX"
local commandaction="Fix"

mkdir "${rootdir}/.openttd/baseset"
cp "${serverfiles}/grapics_set/opengfx-0.6.0.tar" "${rootdir}/.openttd/baseset"