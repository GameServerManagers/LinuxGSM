#!/bin/bash
# LinuxGSM fix_sdtd.sh module
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Contributors: http://linuxgsm.com/contrib
# Description: Resolves various issues with 7 Days to Die.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}/7DaysToDieServer_Data/Plugins/x86_64"
