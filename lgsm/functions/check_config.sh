#!/bin/bash
# LinuxGSM check_config.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Checks if the server config is missing and warns the user if needed.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ -n "${servercfgfullpath}" ]&&[ ! -f "${servercfgfullpath}" ]; then
	fn_print_dots ""
	fn_print_warn_nl "Configuration file missing!"
	echo -e "${servercfgfullpath}"
	fn_script_log_warn "Configuration file missing!"
	fn_script_log_warn "${servercfgfullpath}"
	install_config.sh
fi

if [ "${shortname}" == "rust" ]&&[ -v rconpassword ]&&[ -z "${rconpassword}" ]; then
	fn_print_dots ""
	fn_print_fail_nl "RCON password is not set"
	fn_script_log_warn "RCON password is not set"
elif [ -v rconpassword ]&&[ "${rconpassword}" == "CHANGE_ME" ]; then
	fn_print_dots ""
	fn_print_warn_nl "Default RCON Password detected"
	fn_script_log_warn "Default RCON Password detected"
fi
