#!/bin/bash
# LinuxGSM fix_wurm.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with ARK: Survival Evolved.

# Copies steamclient.so to correct location
if [ ! -f "${serverfiles}/nativelibs" ]; then
	cp -f "${serverfiles}/linux64/steamclient.so" "${serverfiles}/nativelibs"
fi

# First run requires start with no parms
# After first run new dirs are created
if [ ! -d "${serverfiles}/Creative" ]; then
	parms=""
	fixbypass=1
	exitbypass=1
	command_start.sh
	sleep 10
	command_stop.sh
fi