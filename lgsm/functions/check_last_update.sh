#!/bin/bash
# LinuxGSM check_last_update.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Checks lock file to see when last update happened.
# Will reboot server if instance not rebooted since update.

if [ -f "${lockdir}/${selfname}-laststart.lock" ]; then
	laststart=$(cat "${lockdir}/${selfname}-laststart.lock")
fi
if [ -f "${lockdir}/lastupdate.lock" ]; then
	lastupdate=$(cat "${lockdir}/lastupdate.lock")
fi

check_status.sh
if [ -f "${lockdir}/lastupdate.lock" ]&&[ "${status}" != "0" ]; then
	if [ ! -f "${lockdir}/${selfname}-laststart.lock" ]||[ "${laststart}" -lt "${lastupdate}" ]; then
		fn_print_info "${selfname} has not been restarted since last update"
		fn_script_log_info "${selfname} has not been restarted since last update"
		command_restart.sh
	fi
fi
