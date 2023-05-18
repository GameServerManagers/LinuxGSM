#!/bin/bash
# LinuxGSM fix_hw.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves various issues with Ballistic Overkill.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}:${serverfiles}/BODS_Data/Plugins/x86_64"
