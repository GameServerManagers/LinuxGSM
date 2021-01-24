#!/bin/bash
# LinuxGSM check_executable.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Checks if server executable exists.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Check if executable exists
if [ ! -f "${executabledir}/${execname}" ]; then
	fn_print_fail_nl "executable was not found"
	echo -e "* ${executabledir}/${execname}"
	if [ -d "${lgsmlogdir}" ]; then
		fn_script_log_fatal "Executable was not found: ${executabledir}/${execname}"
	fi
	unset exitbypass
	core_exit.sh
fi
