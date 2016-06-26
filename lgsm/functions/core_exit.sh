#!/bin/bash
# LGSM core_exit.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Description: handles exiting of LGSM by running and reporting an exit code.

if [ -n "${exitcode}" ]||[ "${exitcode}" != "0" ]; then
	if [ "${exitcode}" == "1" ]; then
		fn_script_log_fatal "Exiting with code: ${exitcode}"
	elif [ "${exitcode}" == "2" ]; then
		fn_script_log_error "Exiting with code: ${exitcode}"
	elif [ "${exitcode}" == "3" ]; then
		fn_script_log_warn "Exiting with code: ${exitcode}"
	else
		fn_script_log "Exiting with code: ${exitcode}"
	fi
	exit ${exitcode}
else
	exitcode=0
fi

if [ -f ".dev-debug" ]; then
	echo "Exiting with code: ${exitcode}"
fi

