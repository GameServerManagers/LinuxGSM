#!/bin/bash
# LinuxGSM check_executable.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Checks if executable exists.

local commandname="CHECK"
function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Check if executable exists
if [ ! -f "${executabledir}/${execname}" ]; then
	fn_script_log_warn "Executable was not found: ${executabledir}/${execname}"
	if [ -d "${lgsmlogdir}" ]; then
		fn_print_fail_nl "Executable was not found:"
		echo " * ${executabledir}/${execname}"
	fi
	exitcode="1"
	core_exit.sh
fi
