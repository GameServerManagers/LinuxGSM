#!/bin/bash
# LinuxGSM command_version.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Will run update-lgsm if gameserver.sh and modules version does not match
# this will allow gameserver.sh to update - useful for multi instance servers.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ -n "${modulesversion}" ]&&[ -n "${version}" ]&&[ "${version}" != "${modulesversion}" ]; then
	exitbypass=1
	echo -e ""
	fn_print_error_nl "LinuxGSM version mismatch"
	echo -e ""
	echo -e "* ${selfname}: ${version}"
	echo -e "* modules: ${modulesversion}"
	echo -e ""
	fn_sleep_time
	fn_script_log_error "LinuxGSM Version mismatch: ${selfname}: ${version}: modules: ${modulesversion}"
	command_update_linuxgsm.sh
	fn_firstcommand_reset
fi
