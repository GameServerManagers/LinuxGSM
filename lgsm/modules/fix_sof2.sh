#!/bin/bash
# LinuxGSM fix_rust.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Soldier of Fortune 2.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Fixes: error while loading shared libraries: libcxa.so.1
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}"
