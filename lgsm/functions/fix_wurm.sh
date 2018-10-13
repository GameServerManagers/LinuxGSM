#!/bin/bash
# LinuxGSM fix_wurm.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with ARK: Survival Evolved.

# Copies steamclient.so to correct location
if [ ! -f "${serverfiles}/nativelibs" ]; then
	cp -f "${serverfiles}/linux64/steamclient.so" "${serverfiles}/nativelibs"
fi