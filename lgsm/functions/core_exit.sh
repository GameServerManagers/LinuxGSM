#!/bin/bash
# LGSM core_exit.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: handles exiting of LGSM by running and reporting an exit code.

fn_exit_dev_debug(){
	if [ -f "${rootdir}/.dev-debug" ]; then
		echo ""
		echo "${selfname} exiting with code: ${exitcode}"
	fi
}

if [ -n "${exitcode}" ]&&[ "${exitcode}" != "0" ]; then
	if [ "${exitcode}" == "1" ]; then
		fn_script_log_fatal "${selfname} exiting with code: ${exitcode}"
	elif [ "${exitcode}" == "2" ]; then
		fn_script_log_error "${selfname} exiting with code: ${exitcode}"
	elif [ "${exitcode}" == "3" ]; then
		fn_script_log_warn "${selfname} exiting with code: ${exitcode}"
	else
		fn_script_log_warn "${selfname} exiting with code: ${exitcode}"
	fi
	fn_exit_dev_debug
	# remove trap.
	trap - INT
	exit ${exitcode}
elif [ -n "${exitbypass}" ]; then
	unset exitbypass
else
	exitcode=0
	fn_script_log_pass "${selfname} exiting with code: ${exitcode}"
	fn_exit_dev_debug
	# remove trap.
	trap - INT
	exit ${exitcode}
fi

