#!/bin/bash
# LinuxGSM fix_sdtd.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with 7 Days to Die.

modulegroup="FIX"
function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}"
