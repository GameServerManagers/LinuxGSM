#!/bin/bash
# query_gamedig.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Querys a gameserver using node-gamedig.
# https://github.com/sonicsnes/node-gamedig

#Check if gamedig and jq are installed
if [ "$(command -v gamedig 2>/dev/null)" ]&&[ "$(command -v jq 2>/dev/null)" ]; then

		if [ "${engine}" == "idtech3_ql" ]; then
			local engine="quakelive"
		elif [ "${gamename}" == "Killing Floor 2" ]; then
			local engine="unreal4"
		fi

		local engine_query_array=( avalanche3.0 madness quakelive realvirtuality refractor source goldsource spark starbound unity3d unreal4 )
		for engine_query in "${engine_query_array[@]}"
		do
			if [ "${engine_query}" == "${engine}" ]; then
				gamedigengine="protocol-valve"
			fi
		done

		local engine_query_array=( avalanche2.0 )
		for engine_query in "${engine_query_array[@]}"
		do
			if [ "${engine_query}" == "${engine}" ]; then
				gamedigengine="jc2mp"
			fi
		done

		local engine_query_array=( idtech2 iw2.0 )
		for engine_query in "${engine_query_array[@]}"
		do
			if [ "${engine_query}" == "${engine}" ]; then
				gamedigengine="protocol-quake2"
			fi
		done

		local engine_query_array=( idtech3 quake iw3.0 )
		for engine_query in "${engine_query_array[@]}"
		do
			if [ "${engine_query}" == "${engine}" ]; then
				gamedigengine="protocol-quake3"
			fi
		done

		local shortname_query_array=( ts3 )
		for shortname_query in "${shortname_query_array[@]}"
		do
			if [ "${shortname_query}" == "${shortname}" ]; then
				gamedigengine="teamspeak3"
			fi
		done

		local engine_query_array=( unreal )
		for engine_query in "${engine_query_array[@]}"
		do
			if [ "${engine_query}" == "${engine}" ]; then
				gamedigengine="ut"
			fi
		done

	# will bypass query if server offline
	check_status.sh
	if [ "${status}" != "0" ]; then
		# checks if query is working 0 = pass
		querystatus=$(gamedig --type "${gamedigengine}" --host "${ip}" --query_port "${queryport}" | jq '.error|length')
		# raw output
		gamedigraw=$(gamedig --type "${gamedigengine}" --host "${ip}" --query_port "${queryport}")

		# server name
		gdname=$(echo "${gamedigraw}" | jq -re '.name')
		if [ "${gdname}" == "null" ]; then
			gdname=
		fi

		# numplayers
		gdplayers=$(echo "${gamedigraw}" | jq -re '.players|length')
		if [ "${gdplayers}" == "null" ]; then
			gdplayers=
		fi

		# maxplayers
		gdmaxplayers=$(echo "${gamedigraw}" | jq -re '.maxplayers|length')
		if [ "${gdmaxplayers}" == "null" ]; then
			maxplayers=
		fi

		# current map
		gdmap=$(echo "${gamedigraw}" | jq -re '.map')
		if [ "${gdmap}" == "null" ]; then
			gdmap=
		fi

		# numbots
		gdbots=$(echo "${gamedigraw}" | jq -re '.raw.numbots')
		if [ "${gdbots}" == "null" ]; then
			gdbots=
		fi
	fi
fi