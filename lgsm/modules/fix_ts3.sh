#!/bin/bash
# LinuxGSM fix_ts3.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves various issues with Teamspeak 3.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Fixes: makes libmariadb2 available #1924.
if [ ! -f "${serverfiles}/libmariadb.so.2" ]; then
	fixname="libmariadb.so.2"
	fn_fix_msg_start
	cp "${serverfiles}/redist/libmariadb.so.2" "${serverfiles}/libmariadb.so.2"
	fn_fix_msg_end
fi

# Fixes: failed to register local accounting service: No such file or directory.
accountingfile="/dev/shm/7gbhujb54g8z9hu43jre8"
if [ -f "${accountingfile}" ]&&[ "${status}" == "0" ]; then
	# Check permissions for the file if the current user owns it, if not exit.
	if [ "$( stat -c %U ${accountingfile})" == "$(whoami)" ]; then
		fixname="Delete file ${accountingfile}"
		fn_fix_msg_start
		rm -f "${accountingfile}"
		fn_fix_msg_end
	# file is not owned by the current user and needs to be deleted manually.
	else
		fn_print_error_nl "File ${accountingfile} is not owned by $(whoami) and needs to be deleted manually"
		fn_script_log_fatal "File ${accountingfile} is not owned by $(whoami) and needs to be deleted manually"
		core_exit.sh
	fi
fi
