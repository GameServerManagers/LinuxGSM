#!/bin/bash
# LinuxGSM fix_ges.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with GoldenEye: Source.


function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Fixes: MALLOC_CHECK_ needing to be set to 0.
export MALLOC_CHECK_=0
