#!/bin/bash
# LGSM core_getopt.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="300116"

# Description: getopt arguments.

# This now uses the gamedata files, it creates a settings file named scriptactions
# This is processed into the pieces needed to execute commands and display usage.

fn_getopt_generic(){
	USAGE=()
	while IFS='' read -r line || [[ -n "$line" ]]; do
		IFS='|' read -ra field <<< "${line}"
		for opt in ${field[0]}; do
			if [ "${getopt}" == "${opt}" ]; then
				runcmd="${field[1]}"
				break 2
			fi
		done
		if [ -z $optlen ] || [ ${#opt} -gt $optlen ]; then
			optlen=${#opt}
		fi
		USAGE+=("\e[34m${opt}|\e[0m${field[2]}")
	done < <(sed -e 's/"//g' -e 's/=/ /g' "${settingsdir}/scriptactions")
	if [ "${runcmd}" != "" ]; then
		eval "${runcmd}"
		exit
	fi
	echo "Usage: $0 [option]"
	echo "${gamename} - Linux Game Server Manager - Version ${version}"
	echo "http://gameservermanagers.com/${selfname}"
	echo -e ""
	echo -e "\e[93mCommands\e[0m"
	for row in "${USAGE[@]}"; do
		IFS='|' read -ra action <<< "${row}"
		printf "%-$(($optlen+5))b %-$(($optlen+15))b\n"	"${action[0]}" "${action[1]}"
	done
	exit
}
fn_getopt_generic
