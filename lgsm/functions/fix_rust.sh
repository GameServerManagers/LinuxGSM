#!/bin/bash
# LinuxGSM fix_rust.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves startup issue with Rust.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Fixes: [Raknet] Server Shutting Down (Shutting Down).
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}:${serverfiles}/RustDedicated_Data/Plugins/x86_64"
