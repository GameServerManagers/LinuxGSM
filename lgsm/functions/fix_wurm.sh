#!/bin/bash
# LinuxGSM fix_wurm.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with Wurm Unlimited.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# First run requires start with no parms.
# After first run new dirs are created.
if [ ! -d "${serverfiles}/Creative" ]; then
	parmsbypass=1
	fixbypass=1
	exitbypass=1
	command_start.sh
	fn_firstcommand_reset
	sleep 10
	exitbypass=1
	command_stop.sh
	fn_firstcommand_reset
	unset parmsbypass
fi
