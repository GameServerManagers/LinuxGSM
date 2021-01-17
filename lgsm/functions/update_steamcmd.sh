#!/bin/bash
# LinuxGSM update_steamcmd.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Handles updating using SteamCMD.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# init steamcmd functions
core_steamcmd.sh

# The location where the builds are checked and downloaded.
remotelocation="SteamCMD"
check.sh

fn_print_dots "${remotelocation}"

if [ "${forceupdate}" == "1" ]; then
	# forceupdate bypasses update checks.
	if [ "${status}" != "0" ]; then
		fn_print_restart_warning
		exitbypass=1
		command_stop.sh
		fn_firstcommand_reset
		fn_dl_steamcmd
		date +%s > "${lockdir}/lastupdate.lock"
		exitbypass=1
		command_start.sh
		fn_firstcommand_reset
	else
		fn_dl_steamcmd
		date +%s > "${lockdir}/lastupdate.lock"
	fi
else
	fn_update_steamcmd_localbuild
	fn_update_steamcmd_remotebuild
	fn_update_steamcmd_compare
fi
