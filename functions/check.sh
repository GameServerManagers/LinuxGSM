#!/bin/bash
# LGSM fn_check function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

# Description: Overall function for managing checks.
# Runs checks that will either halt on or fix an issue.

array_contains () {
    local seeking=$1; shift
    local in=1
    for element; do
        if [ ${element} == ${seeking} ]; then
            in=0
            break
        fi
    done
    return $in
}


check_root.sh

if [ "${getopt}" != "install" ]||[ "${getopt}" != "auto-install" ]; then
	check_systemdir.sh
fi

local allowed_commands_array=( backup console debug details map-compressor monitor start stop update validate )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${getopt}" ]; then
		check_logs.sh
	fi
done

local allowed_commands_array=( debug details monitor start stop )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${getopt}" ]; then
		check_ip.sh
	fi
done

local allowed_commands_array=( debug install start stop update validate )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${getopt}" ]; then
		check_steamcmd.sh
	fi
done

local allowed_commands_array=( console start stop )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${getopt}" ]; then
		check_tmux.sh
	fi
done