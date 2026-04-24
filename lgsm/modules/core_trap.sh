#!/bin/bash
# LinuxGSM core_trap.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Handles CTRL-C trap to give an exit code.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_exit_trap() {
	local saved_exit_status=$?
	echo -e ""
	if [ -z "${exitcode}" ]; then
		exitcode=${saved_exit_status}
	fi

	if [ -z "${exitcode}" ]; then
		exitcode=0
	fi
	core_exit.sh
}

# trap to give an exit code.
trap fn_exit_trap INT
