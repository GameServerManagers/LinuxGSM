#!/bin/bash
# LinuxGSM core_exit.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Handles exiting of LinuxGSM by running and reporting an exit code.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_exit_dev_debug(){
	if [ -f "${rootdir}/.dev-debug" ]; then
		echo -e ""
		echo -e "${functionselfname} exiting with code: ${exitcode}"
		if [ -f "${rootdir}/dev-debug.log" ]; then
			grep "functionfile=" "${rootdir}/dev-debug.log" | sed 's/functionfile=//g' > "${rootdir}/dev-debug-function-order.log"
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
elif [ "${exitcode}" ]&&[ "${exitcode}" != "0" ]; then
	# List LinuxGSM version in logs
	fn_script_log_info "LinuxGSM version: ${version}"
	if [ "${exitcode}" == "1" ]; then
		fn_script_log_fatal "${functionselfname} exiting with code: ${exitcode}"
	elif [ "${exitcode}" == "2" ]; then
		fn_script_log_error "${functionselfname} exiting with code: ${exitcode}"
	elif [ "${exitcode}" == "3" ]; then
		fn_script_log_warn "${functionselfname} exiting with code: ${exitcode}"
	else
		fn_script_log_warn "${functionselfname} exiting with code: ${exitcode}"
	fi
	fn_exit_dev_debug
	# remove trap.
	trap - INT
	exit "${exitcode}"
elif [ "${exitcode}" ]&&[ "${exitcode}" == "0" ]; then
	# List LinuxGSM version in logs
	fn_script_log_info "LinuxGSM version: ${version}"
	fn_script_log_pass "${functionselfname} exiting with code: ${exitcode}"
	fn_exit_dev_debug
	# remove trap.
	trap - INT
	exit "${exitcode}"
else
	# List LinuxGSM version in logs
	fn_script_log_info "LinuxGSM version: ${version}"
	fn_print_error "No exit code set"
	fn_script_log_pass "${functionselfname} exiting with code: NOT SET"
	fn_exit_dev_debug
	# remove trap.
	trap - INT
	exit "${exitcode}"
fi
