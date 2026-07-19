#!/bin/bash
# LinuxGSM check_root.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Checks if the user tried to run the script as root.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ "$(whoami)" == "root" ]; then
	if [ "${commandname}" != "INSTALL" ]; then
		fn_print_fail_nl "Do NOT run as root!"
		if [ -d "${lgsmlogdir}" ]; then
			fn_script_log_fail "${selfname} attempted to run as root."
		else
			# Forces exit code is log does not yet exist.
			exitcode=1
		fi
		core_exit.sh
	fi
fi
