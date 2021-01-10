#!/bin/bash
# LinuxGSM fix_rust.sh module
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Contributors: http://linuxgsm.com/contrib
# Description: Resolves various issues with Soldier of Fortune 2.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
# Fixes: error while loading shared libraries: libcxa.so.1
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}"
