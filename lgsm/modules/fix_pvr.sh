#!/bin/bash
# LinuxGSM fix_pvr.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves various issues with Pavlov VR.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ ! -f "${serverfiles}/linux64/libc++.so" ] && [ -f "/usr/lib/x86_64-linux-gnu/libc++.so.1" ]; then
	cp "/usr/lib/x86_64-linux-gnu/libc++.so.1" "${serverfiles}/linux64/libc++.so"
fi

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}:${serverfiles}/linux64"
