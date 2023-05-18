#!/bin/bash
# LinuxGSM check_system_dir.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Checks if systemdir/serverfiles is accessible.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ "${commandname}" != "VALIDATE" ]; then
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
