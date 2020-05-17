#!/bin/bash
# LinuxGSM command_version.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Will run update-lgsm if gameserver.sh and modules version does not match
# this will allow gameserver.sh to update - useful for multi instance servers.

if [ -n "${modulesversion}" ]&&[ -n "${version}" ]&&[ "${version}" != "${modulesversion}" ]; then
	exitbypass=1
	fn_print_error "Version mismatch"
	echo -en "${selfname}: ${version}"
	echo -en "modules: ${modulesversion}"
	echo -en ""
	fn_script_log_error "Version mismatch: ${selfname}: ${version}: modules: ${modulesversion}"
	command_update_linuxgsm.sh
fi
