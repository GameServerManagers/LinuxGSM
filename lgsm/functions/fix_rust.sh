#!/bin/bash
# LinuxGSM fix_rust.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves startup issue with Rust.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Fixes: [Raknet] Server Shutting Down (Shutting Down).
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}:${serverfiles}/RustDedicated_Data/Plugins/x86_64"

# Part of random seed feature.
# If seed is not defined by user generate a seed file.
if [ -z "${seed}" ]; then
	if [ ! -f "${datadir}/${selfname}-seed.txt" ]; then
		shuf -i 1-2147483647 -n 1 > "${datadir}/${selfname}-seed.txt"
	fi
	seed="$(cat "${datadir}/${selfname}-seed.txt")"
	randomseed=1
fi
