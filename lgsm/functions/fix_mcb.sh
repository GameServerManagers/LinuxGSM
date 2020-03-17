#!/bin/bash
# LinuxGSM fix_mcb.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves possible startup issue with Minecraft Bedrock

local modulename="FIX"
local commandaction="Fix"

# official docs state that the server should be started with: LD_LIBRARY_PATH=. ./bedrock_server
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}"
