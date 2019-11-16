#!/bin/bash
# query_gamedig.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Querys a gameserver using node-gamedig.
# https://github.com/sonicsnes/node-gamedig

# will bypass query if server offline.
check_status.sh
if [ "${status}" != "0" ]; then
	# checks if query is working null = pass.
	gamedigcmd=$(echo -e "gamedig --type \"${querytype}\" --host \"${ip}\" --port \"${queryport}\"|jq")
	gamedigraw=$(gamedig --type "${querytype}" --host "${ip}" --port "${queryport}")
	querystatus=$(echo -e "${gamedigraw}" | jq '.error|length')

	# server name.
	gdname=$(echo -e "${gamedigraw}" | jq -re '.name')
	if [ "${gdname}" == "null" ]; then
		unset gdname
	fi

	# numplayers.
	gdplayers=$(echo -e "${gamedigraw}" | jq -re '.players')
	if [ "${gdplayers}" == "null" ]; then
		unset gdplayers
	elif [ "${gdplayers}" == "[]" ]; then
		gdplayers=0
	fi

	# maxplayers.
	gdmaxplayers=$(echo -e "${gamedigraw}" | jq -re '.maxplayers')
	if [ "${gdmaxplayers}" == "null" ]; then
		unset maxplayers
	elif [ "${gdmaxplayers}" == "[]" ]; then
		gdmaxplayers=0
	fi

	# current map.
	gdmap=$(echo -e "${gamedigraw}" | jq -re '.map')
	if [ "${gdmap}" == "null" ]; then
		unset gdmap
	fi

	# current gamemode.
	gdgamemode=$(echo -e "${gamedigraw}" | jq -re '.raw.rules.GameMode_s')
	if [ "${gdgamemode}" == "null" ]; then
		unset gdgamemode
	fi

	# numbots.
	gdbots=$(echo -e "${gamedigraw}" | jq -re '.raw.numbots')
	if [ "${gdbots}" == "null" ]||[ "${gdbots}" == "0" ]; then
		unset gdbots
	fi
fi
