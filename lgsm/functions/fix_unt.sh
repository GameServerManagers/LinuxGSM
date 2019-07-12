#!/bin/bash
# LinuxGSM fix_rust.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves startup issue with Unturned

local commandname="FIX"
local commandaction="Fix"

# steamclient.so: cannot open shared object file: No such file or directory
export LD_LIBRARY_PATH="${serverfiles}/linux64:${serverfiles}:$LD_LIBRARY_PATH"
