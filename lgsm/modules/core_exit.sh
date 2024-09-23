#!/bin/bash
# LinuxGSM core_exit.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Handles exiting of LinuxGSM by running and reporting an exit code.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_exit_dev_debug() {
	if [ -f "${rootdir}/.dev-debug" ]; then
		echo -e ""
		echo -e "${moduleselfname} exiting with code: ${exitcode}"
		if [ -f "${rootdir}/dev-debug.log" ]; then
			grep -a "modulefile=" "${rootdir}/dev-debug.log" | sed 's/modulefile=//g' > "${rootdir}/dev-debug-module-order.log"
		elif [ -f "${lgsmlogdir}/dev-debug.log" ]; then
			grep -a "modulefile=" "${lgsmlogdir}/dev-debug.log" | sed 's/modulefile=//g' > "${rootdir}/dev-debug-module-order.log"
		fi
	fi
}

# If running dependency check as root will remove any files that belong to root user.
if [ "$(whoami)" == "root" ]; then
	find "${lgsmdir}"/ -group root -prune -exec rm -rf {} + > /dev/null 2>&1
	find "${logdir}"/ -group root -prune -exec rm -rf {} + > /dev/null 2>&1
fi

if [ "${exitbypass}" ]; then
	unset exitbypass
elif [ "${exitcode}" != "0" ]; then
	# List LinuxGSM version in logs
	fn_script_log_info "LinuxGSM version: ${version}"
	if [ "${exitcode}" == "1" ]; then
		fn_script_log_fail "${moduleselfname} exiting with code: ${exitcode}"
	elif [ "${exitcode}" == "2" ]; then
		fn_script_log_error "${moduleselfname} exiting with code: ${exitcode}"
	elif [ "${exitcode}" == "3" ]; then
		fn_script_log_warn "${moduleselfname} exiting with code: ${exitcode}"
	else
		# if exit code is not set assume error.
		fn_script_log_warn "${moduleselfname} exiting with code: ${exitcode}"
		exitcode=4
	fi
	fn_exit_dev_debug
	# remove trap.
	trap - INT
	exit "${exitcode}"
elif [ "${exitcode}" ] && [ "${exitcode}" == "0" ]; then
	# List LinuxGSM version in logs
	fn_script_log_info "LinuxGSM version: ${version}"
	fn_script_log_pass "${moduleselfname} exiting with code: ${exitcode}"
	fn_exit_dev_debug
	# remove trap.
	trap - INT
	exit "${exitcode}"
else
	# List LinuxGSM version in logs
	fn_script_log_info "LinuxGSM version: ${version}"
	fn_print_error "No exit code set"
	fn_script_log_pass "${moduleselfname} exiting with code: NOT SET"
	fn_exit_dev_debug
	# remove trap.
	trap - INT
	exit "${exitcode}"
fi
