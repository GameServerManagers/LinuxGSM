#!/bin/bash
# LinuxGSM fix_rust.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves startup issue with Unturned

local commandname="FIX"
local commandaction="Fix"

# Fixes: [Raknet] Server Shutting Down (Shutting Down)
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${systemdir}/lib"
