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
		for queryip in "${queryips[@]}"; do
			query_gamedig.sh
			if [ "${querystatus}" == "0" ]; then
				if [ -n "${gdplayers}" ] && [ "${gdplayers}" -ne 0 ]; then
					playersonline="${gdplayers}"
					break
				fi
			fi
		done
	fi
fi
