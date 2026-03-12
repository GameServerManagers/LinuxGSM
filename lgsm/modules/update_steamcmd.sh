#!/bin/bash
# LinuxGSM update_steamcmd.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Handles updating using SteamCMD.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# init steamcmd functions
core_steamcmd.sh

# The location where the builds are checked and downloaded.
remotelocation="SteamCMD"
check.sh

fn_print_dots "${remotelocation}"

if [ "${forceupdate}" == "1" ]; then
	# forceupdate bypasses update checks.
	if [ "${status}" != "0" ] && [ -v "${status}" ]; then
		fn_print_restart_warning
		exitbypass=1
		command_stop.sh
		fn_firstcommand_reset
		date '+%s' > "${lockdir:?}/update.lock"
		fn_dl_steamcmd
		date +%s > "${lockdir}/last-updated.lock"
		exitbypass=1
		command_start.sh
		fn_firstcommand_reset
	else
		fn_dl_steamcmd
		date +%s > "${lockdir}/last-updated.lock"
	fi
else
	fn_update_steamcmd_localbuild
	fn_update_steamcmd_remotebuild
	fn_update_steamcmd_compare
fi
