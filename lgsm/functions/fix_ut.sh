#!/bin/bash
# LinuxGSM fix_ut.sh function
# Author: Alexander Hurd
# Website: https://linuxgsm.com
# Description: Resolves various issues with Unreal Tournament.

modulegroup="FIX"
function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

#Set Binary Executable
echo -e "chmod +x ${executabledir}/${executable}"
chmod +x "${executabledir}/${executable}"
fn_sleep_time
