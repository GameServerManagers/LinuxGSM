#!/bin/bash
# LinuxGSM check_config.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Checks if the server config is missing and warns the user if needed.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ -n "${servercfgfullpath}" ] && [ ! -f "${servercfgfullpath}" ]; then
	fn_print_warn_nl "Configuration file missing!"
	echo -e "${servercfgfullpath}"
	fn_script_log_warn "Configuration file missing!"
	fn_script_log_warn "${servercfgfullpath}"
	install_config.sh
fi

if [ "${shortname}" == "rust" ] && [ -v rconpassword ] && [ -z "${rconpassword}" ]; then
	fn_print_fail_nl "RCON password is not set"
	fn_script_log_warn "RCON password is not set"
elif [ -v rconpassword ] && [ "${rconpassword}" == "CHANGE_ME" ]; then
	fn_print_warn_nl "Default RCON password detected"
	fn_script_log_warn "Default RCON password detected"
elif [ -v httppassword ] && [ "${httppassword}" == "CHANGE_ME" ]; then
	fn_print_warn_nl "Default Web password detected"
	fn_script_log_warn "Default Web password detected"
elif [ -v adminpassword ] && [ "${adminpassword}" == "CHANGE_ME" ]; then
	fn_print_warn_nl "Default Admin password detected"
	fn_script_log_warn "Default Admin password detected"

fi

if [ "${shortname}" == "vh" ] && [ -z "${serverpassword}" ]; then
	fn_print_fail_nl "serverpassword is not set"
	fn_script_log_fail "serverpassword is not set"
elif [ "${shortname}" == "vh" ] && [ "${#serverpassword}" -le "4" ]; then
	fn_print_fail_nl "serverpassword is to short (min 5 chars)"
	fn_script_log_fail "serverpassword is to short (min 5 chars)"
fi
