#!/bin/bash
# LinuxGSM core_exit.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Handles exiting of LinuxGSM by running and reporting an exit code.

fn_exit_dev_debug(){
	if [ -f "${rootdir}/.dev-debug" ]; then
		echo -e ""
		echo -e "${function_selfname} exiting with code: ${exitcode}"
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
	if [ "${exitcode}" == "1" ]; then
		fn_script_log_fatal "${function_selfname} exiting with code: ${exitcode}"
	elif [ "${exitcode}" == "2" ]; then
		fn_script_log_error "${function_selfname} exiting with code: ${exitcode}"
	elif [ "${exitcode}" == "3" ]; then
		fn_script_log_warn "${function_selfname} exiting with code: ${exitcode}"
	else
		fn_script_log_warn "${function_selfname} exiting with code: ${exitcode}"
	fi
	fn_exit_dev_debug
	# remove trap.
	trap - INT
	exit "${exitcode}"
else
	fn_script_log_pass "${function_selfname} exiting with code: ${exitcode}"
	fn_exit_dev_debug
	# remove trap.
	trap - INT
	exit "${exitcode}"
fi
