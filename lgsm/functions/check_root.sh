#!/bin/bash
# LinuxGSM check_root.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Checks if the user tried to run the script as root.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ "$(whoami)" = "root" ]; then
	if [ "${commandname}" != "INSTALL" ]; then
		fn_print_fail_nl "Do NOT run this script as root!"
		if [ -d "${lgsmlogdir}" ]; then
			fn_script_log_fatal "${selfname} attempted to run as root."
		fi
		core_exit.sh
	fi
fi
