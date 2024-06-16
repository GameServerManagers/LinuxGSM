#!/bin/bash
# LinuxGSM command_restart.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Restarts the server.

commandname="RESTART"
commandaction="Restarting"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

info_game.sh
if [ "${stoponlyifnoplayers}" == "on" ]; then
	if [ "${querymode}" == "2" ] || [ "${querymode}" == "3" ]; then
		for queryip in "${queryips[@]}"; do
			query_gamedig.sh
			if [ "${querystatus}" == "0" ]; then
				if [ -n "${gdplayers}" ] && [ "${gdplayers}" -ne 0 ]; then
					fn_print_info_nl "${gdplayers} players are on the server: restart postponed"
					fn_script_log_info "${gdplayers} players are on the server: restart postponed"
					echo "${gdplayers}" > "${lockdir:?}/${selfname}-player-numbers.lock"
					date '+%s' > "${lockdir:?}/${selfname}-restart-request.lock"
					core_exit.sh
				fi
			fi
		done
	fi
fi
exitbypass=1
command_stop.sh
command_start.sh
fn_firstcommand_reset
core_exit.sh
