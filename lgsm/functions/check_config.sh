#!/bin/bash
# LinuxGSM check_config.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Checks if the server config is missing and warns the user if needed.

local commandname="CHECK"
local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

if [ ! -e "${servercfgfullpath}" ]; then
	if [ "${shortname}" != "hw" ]&&[ "${shortname}" != "ut3" ]&&[ "${shortname}" != "kf2" ]; then
		fn_print_dots ""
		fn_print_warn_nl "Configuration file missing!"
		echo -e "${servercfgfullpath}"
		fn_script_log_warn "Configuration file missing!"
		fn_script_log_warn "${servercfgfullpath}"
		install_config.sh
	fi
fi

if [ "${shortname}" == "rust" ]; then
	if  [ -z "${rconpassword}" ]; then
		fn_print_dots ""
		fn_print_fail_nl "RCON password is not set!"
		echo -e "  * Not setting an RCON password causes issues with ${gamename}"
		fn_script_log_fatal "RCON password is not set"
		fn_script_log_fatal "Not setting an RCON password causes issues with ${gamename}"
		core_exit.sh
	elif [ "${rconpassword}" == "CHANGE_ME" ]; then
		fn_print_dots ""
		fn_print_warn_nl "Default RCON Password detected!"
		echo -e " * Having ${rconpassword} as a password is not very safe."
		fn_script_log_warn "Default RCON Password detected"
	fi
fi
