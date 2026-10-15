#!/bin/bash
# LinuxGSM check_players_online.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Checks if players are on the server.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

playersonline=""
playerscounted=""
playercountunavailable=""
if [ "${stoponlyifnoplayers}" == "on" ] || [ "${playercheckforce}" == "1" ]; then
	if [ "${querymode}" != "2" ] && [ "${querymode}" != "3" ]; then
		playercountunavailable="querymode ${querymode} cannot count players"
	elif [ ! -f "${lgsmdir}/node_modules/gamedig/bin/gamedig.js" ] && [ ! "$(command -v gamedig 2> /dev/null)" ]; then
		playercountunavailable="gamedig is not installed"
	elif [ ! "$(command -v jq 2> /dev/null)" ]; then
		playercountunavailable="jq is not installed"
	else
		for queryip in "${queryips[@]}"; do
			query_gamedig.sh
			if [ "${querystatus}" == "0" ]; then
				playerscounted="1"
				if [ -n "${gdplayers}" ] && [ "${gdplayers}" -ne 0 ]; then
					playersonline="${gdplayers}"
					break
				fi
			fi
		done
		if [ "${playerscounted}" != "1" ]; then
			playercountunavailable="query failed"
		fi
	fi
	# The player count could not be determined. Fail open (proceed as if empty) rather than
	# block the server indefinitely, but warn clearly since the check did not actually run.
	if [ -n "${playercountunavailable}" ] && [ "${playercheckforce}" != "1" ]; then
		fn_print_warn_nl "Unable to determine player count (${playercountunavailable}): stoponlyifnoplayers check skipped"
		fn_script_log_warn "Unable to determine player count (${playercountunavailable}): stoponlyifnoplayers check skipped"
	fi
fi
