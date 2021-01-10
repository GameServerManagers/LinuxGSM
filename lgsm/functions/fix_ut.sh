#!/bin/bash
# LinuxGSM fix_ut.sh module
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Contributors: http://linuxgsm.com/contrib
# Description: Resolves various issues with Unreal Tournament.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

#Set Binary Executable
echo -e "chmod +x ${executabledir}/${executable}"
chmod +x "${executabledir}/${executable}"
fn_sleep_time
