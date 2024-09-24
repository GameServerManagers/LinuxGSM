#!/bin/bash
# LinuxGSM check_logs.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Checks if log files exist.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_check_logs() {
	fn_print_dots "Checking for log files"
	fn_print_info_nl "Checking for log files: Creating log files"
	checklogs=1
	install_logs.sh
}

# Create directories for the script and console logs.
if [ ! -d "${lgsmlogdir}" ] || [ ! -d "${consolelogdir}" ]; then
	fn_check_logs
fi

# Create gamelogdir.
# If variable exists gamelogdir exists and log/server does not.
if [ "${gamelogdir}" ] && [ -d "${gamelogdir}" ] && [ ! -d "${logdir}/server" ]; then
	fn_check_logs
fi

# Create Steam log symlink if missing
if [ ! -d "${logdir}/steam" ] && [ -n "${appid}" ]; then
	fn_check_logs
fi
