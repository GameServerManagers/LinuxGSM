#!/bin/bash
# LinuxGSM core_trap.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Handles CTRL-C trap to give an exit code.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_exit_trap(){
	if [ -z "${exitcode}" ]; then
		exitcode=$?
	fi
	echo -e ""
	if [ -z "${exitcode}" ]; then
		exitcode=0
	fi
	core_exit.sh
}

# trap to give an exit code.
trap fn_exit_trap INT
