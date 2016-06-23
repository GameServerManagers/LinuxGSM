#!/bin/bash
# LGSM core_exit.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Description: handles exiting of LGSM by running and reporting an exit code.

if [ "${exitcode}" != "0" ]; then
	if [ "${exitcode}" == "1" ]; then
		fn_script_log_fatal "Exiting with exit code: ${exitcode}"
	if [ "${exitcode}" == "2" ]; then
		fn_script_log_error "Exiting with exit code: ${exitcode}"
	if [ "${exitcode}" == "3" ]; then
		fn_script_log_warn "Exiting with exit code: ${exitcode}"
	else
		fn_script_log "Exiting with exit code: ${exitcode}"
	fi
else
	fn_script_log_pass "Exiting with exit code: ${exitcode}"
fi

exit ${exitcode}