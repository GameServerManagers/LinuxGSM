#!/bin/bash
# LinuxGSM fix_rw.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves startup issue with Rising World

commandname="FIX"
commandaction="Fix"

export LD_LIBRARY_PATH="${serverfiles}/linux64:${serverfiles}:$LD_LIBRARY_PATH"