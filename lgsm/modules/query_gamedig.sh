#!/bin/bash
# LinuxGSM query_gamedig.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Querys a gameserver using node-gamedig.
# https://github.com/gamedig/node-gamedig

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
# Default query status to failure. Will be changed to 0 if query is successful.
querystatus="2"
# Check if gamedig and jq are installed.

if [ -f "${lgsmdir}/node_modules/gamedig/bin/gamedig.js" ]; then
	gamedigbinary="${lgsmdir}/node_modules/gamedig/bin/gamedig.js"
else
	gamedigbinary="gamedig"
fi

if [ "$(command -v "${gamedigbinary}" 2> /dev/null)" ] && [ "$(command -v jq 2> /dev/null)" ]; then

	# will bypass query if server offline.
	check_status.sh
	if [ "${status}" != "0" ]; then
		# GameDig requires you use the voice port when querying.
		if [ "${querytype}" == "teamspeak3" ]; then
			queryport="${port}"
		fi
		# checks if query is working null = pass.
		gamedigcmd=$(echo -e "${gamedigbinary} --type \"${querytype}\" \"${queryip}:${queryport}\"|jq")
		gamedigraw=$(${gamedigbinary} --type "${querytype}" "${queryip}:${queryport}")
		querystatus=$(echo "${gamedigraw}" | jq '.error|length')

		if [ "${querytype}" == "teamspeak3" ]; then
			fn_info_game_ts3
		fi

		# server name.
		gdname=$(echo "${gamedigraw}" | jq -re '.name')
		if [ "${gdname}" == "null" ]; then
			unset gdname
		fi

		# numplayers.
		if [ "${querytype}" == "minecraft" ]; then
			gdplayers=$(echo "${gamedigraw}" | jq -re '.players | length-1')
		elif [ "${querytype}" == "teamspeak3" ]; then
			gdplayers=$(echo "${gamedigraw}" | jq -re '.raw.virtualserver_clientsonline')
		else
			gdplayers=$(echo "${gamedigraw}" | jq -re '.players | length')
		fi
		if [ "${gdplayers}" == "null" ]; then
			unset gdplayers
		elif [ "${gdplayers}" == "[]" ] || [ "${gdplayers}" == "-1" ]; then
			gdplayers=0
		fi

		# maxplayers.
		gdmaxplayers=$(echo "${gamedigraw}" | jq -re '.maxplayers')
		if [ "${gdmaxplayers}" == "null" ]; then
			unset gdmaxplayers
		elif [ "${gdmaxplayers}" == "[]" ]; then
			gdmaxplayers=0
		fi

		# current map.
		gdmap=$(echo "${gamedigraw}" | jq -re '.map')
		if [ "${gdmap}" == "null" ]; then
			unset gdmap
		fi

		# current gamemode.
		gdgamemode=$(echo "${gamedigraw}" | jq -re '.raw.rules.GameMode_s')
		if [ "${gdgamemode}" == "null" ]; then
			unset gdgamemode
		fi

		# numbots.
		gdbots=$(echo "${gamedigraw}" | jq -re '.bots | length')
		if [ "${gdbots}" == "null" ] || [ "${gdbots}" == "0" ]; then
			unset gdbots
		fi

		# server version.
		if [ "${querytype}" == "teamspeak3" ]; then
			gdversion=$(echo "${gamedigraw}" | jq -re '.raw.virtualserver_version')
		else
			gdversion=$(echo "${gamedigraw}" | jq -re '.raw.version')
		fi

		if [ "${gdversion}" == "null" ] || [ "${gdversion}" == "0" ]; then
			unset gdversion
		fi
	fi
fi
