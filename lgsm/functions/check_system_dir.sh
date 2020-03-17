#!/bin/bash
# LinuxGSM check_system_dir.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Checks if systemdir/serverfiles is accessible.

local modulename="CHECK"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ "${function_selfname}" != "command_validate.sh" ]; then
	checkdir="${serverfiles}"
else
	checkdir="${systemdir}"
fi

if [ ! -d "${checkdir}" ]; then
	fn_print_fail_nl "Cannot access ${checkdir}: No such directory"
	if [ -d "${lgsmlogdir}" ]; then
		fn_script_log_fatal "Cannot access ${checkdir}: No such directory."
	fi
	core_exit.sh
fi
