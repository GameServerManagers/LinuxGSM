#!/bin/bash
# LinuxGSM command_restart.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Restarts the server.

commandname="RESTART"
commandaction="Restarting"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

check.sh
info_game.sh
check_players_online.sh
if [ -n "${playersonline}" ]; then
	fn_print_info_nl "${playersonline} players are on the server: restart postponed"
	fn_script_log_info "${playersonline} players are on the server: restart postponed"
	echo "${playersonline}" > "${lockdir:?}/${selfname}-player-numbers.lock"
	date '+%s' > "${lockdir:?}/${selfname}-restart-request.lock"
	core_exit.sh
fi
exitbypass=1
command_stop.sh
command_start.sh
fn_firstcommand_reset
core_exit.sh
