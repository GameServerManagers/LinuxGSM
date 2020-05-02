#!/bin/bash
# LinuxGSM fix_rust.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves startup issue with Unturned.


function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# steamclient.so: cannot open shared object file: No such file or directory
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}:${serverfiles}/linux64"
