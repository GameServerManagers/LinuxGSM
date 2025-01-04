#!/bin/bash
# LinuxGSM fix_ts3.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Teamspeak 3.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Creates a blank ts3server.ini if it does not exist.
if [ ! -f "${servercfgfullpath}" ]; then
	fixname="create blank ${servercfg}"
	fn_fix_msg_start
	touch "${servercfgfullpath}"
	fn_fix_msg_end
fi

# Accept license.
if [ ! -f "${executabledir}/.ts3server_license_accepted" ]; then
	install_eula.sh
fi

# Fixes: makes libmariadb2 available #1924.
if [ ! -f "${serverfiles}/libmariadb.so.2" ]; then
	fixname="libmariadb.so.2"
	fn_fix_msg_start
	cp "${serverfiles}/redist/libmariadb.so.2" "${serverfiles}/libmariadb.so.2"
	fn_fix_msg_end
fi

# Fixes: failed to register local accounting service: No such file or directory.
accountingfile="/dev/shm/7gbhujb54g8z9hu43jre8"
if [ -f "${accountingfile}" ] && [ "${status}" == "0" ]; then
	# Check permissions for the file if the current user owns it, if not exit.
	if [ "$(stat -c %U ${accountingfile})" == "$(whoami)" ]; then
		fixname="Delete file ${accountingfile}"
		fn_fix_msg_start
		rm -f "${accountingfile}"
		fn_fix_msg_end
	# file is not owned by the current user and needs to be deleted manually.
	else
		fn_print_error_nl "File ${accountingfile} is not owned by $(whoami) and needs to be deleted manually"
		fn_script_log_fail "File ${accountingfile} is not owned by $(whoami) and needs to be deleted manually"
		core_exit.sh
	fi
fi
