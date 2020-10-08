#!/bin/bash
# LinuxGSM fix_col.sh function
# Author: Christian Birk
# Website: https://linuxgsm.com
# Description: Resolves issue that a random seed is generated before the first start of the server

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ -f "${servercfgfullpath}" ]; then

	if [ "${postinstall}" == "1" ]; then
		# check if seed is set "RNDSEED"
		currentseed=$(jq -r '.NewOptions.Seed' "${servercfgfullpath}" )
		defaultseed="RNDSEED"
		# check if seed is set
		if [ "${currentseed}" == "${defaultseed}" ]; then
			fixname="set inital random seed for server"
			fn_fix_msg_start
			fn_script_log_info "set initial random seed for server"
			random=$(shuf -i 1-1000000 -n 1)
			sed -i "s/\"${defaultseed}\"/${random}/g" "${servercfgfullpath}"
			fn_fix_msg_end
		fi
	fi

	worldname=$(jq -r '.NewOptions.WorldName' "${servercfgfullpath}" )

	# this is executed only on the second start of the gameserver to change from generating to load the map
	if [ "${worldname}" != "null" ]; then
		if [ -d "${systemdir}/gamedata/savegames/${worldname}" ]; then
			fn_print_information_nl "changing json to load world, if it already exists"
			sed -i 's/"NewOptions"/"LoadOptions"/' "${servercfgfullpath}"
		fi
	fi
fi
