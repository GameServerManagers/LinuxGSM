#!/bin/bash
# LinuxGSM fix_rust.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves startup issue with Rust.


function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Fixes: [Raknet] Server Shutting Down (Shutting Down).
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${systemdir}/RustDedicated_Data/Plugins/x86_64"
