#!/bin/bash
# LinuxGSM check_system_dir.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Checks if systemdir/serverfiles is accessible.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ ! -d "${serverfiles}" ]; then
	fn_print_fail_nl "Cannot access ${serverfiles}: No such directory"
	if [ -d "${lgsmlogdir}" ]; then
		fn_script_log_fail "Cannot access ${serverfiles}: No such directory."
	fi
	core_exit.sh
fi

if [ ! -d "${systemdir}" ] && [ -z "${CI}" ]; then
	fn_print_fail_nl "Cannot access ${systemdir}: No such directory"
	if [ -d "${lgsmlogdir}" ]; then
		fn_script_log_fail "Cannot access ${systemdir}: No such directory."
	fi
	core_exit.sh
fi
