#!/bin/bash
# LGSM fix_ut.sh function
# Author: Alexander Hurd
# Website: https://gameservermanagers.com
# Description: Resolves various issues with Unreal Tournament.

local commandname="FIX"
local commandaction="Fix"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

#Set Binary Executable
echo "chmod +x ${executabledir}/${executable}"
chmod +x "${executabledir}/${executable}"
sleep 1