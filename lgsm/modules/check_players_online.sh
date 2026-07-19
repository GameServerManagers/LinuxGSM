#!/bin/bash
# LinuxGSM check_players_online.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Queries the server with gamedig and sets ${playersonline} to the
#              current player count when players are connected (empty otherwise).
#              Used by the stoponlyifnoplayers feature to postpone stop/restart.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

playersonline=""
if [ "${stoponlyifnoplayers}" == "on" ]; then
	if [ "${querymode}" == "2" ] || [ "${querymode}" == "3" ]; then
		querysucceeded="0"
		for queryip in "${queryips[@]}"; do
			query_gamedig.sh
			if [ "${querystatus}" == "0" ]; then
				querysucceeded="1"
				if [ -n "${gdplayers}" ] && [ "${gdplayers}" -ne 0 ]; then
					playersonline="${gdplayers}"
					break
				fi
			fi
		done
		# The query failed for every configured IP, so the player count could not be
		# determined. Fail open (proceed as if empty) rather than block the server
		# indefinitely, but warn clearly since the safety check did not actually run.
		if [ "${querysucceeded}" == "0" ]; then
			fn_print_warn_nl "Unable to determine player count: stoponlyifnoplayers check skipped"
			fn_script_log_warn "Unable to determine player count via gamedig: stoponlyifnoplayers check skipped"
		fi
	fi
fi
