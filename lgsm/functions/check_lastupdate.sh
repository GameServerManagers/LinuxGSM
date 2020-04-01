#!/bin/bash
# LinuxGSM check_last_update.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Checks lock file to see when last update happened.

if [ -f "${lockdir}/laststart.lock" ]; then
	laststart=$(cat "${lockdir}/laststart.lock")
fi
if [ -f "${lockdir}/lastupdate.lock" ]; then
	lastupdate=$(cat "${lockdir}/lastupdate.lock")
fi

if [ -n "${laststart}" ]&&[ -n "${lastupdate}" ]&&[ "${laststart}" -lt "${lastupdate}" ]; then
	fn_print_info "${selfname} has not been restarted since last update"
	fn_script_log_info "${selfname} has not been restarted since last update"
	command_restart.sh
fi
