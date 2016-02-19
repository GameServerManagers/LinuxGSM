#!/bin/bash
# LGSM fn_check function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="190216"

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

if [ "${function_selfname}" != "command_install.sh" ] && [ "${function_selfname}" != "update_functions.sh" ]; then
	check_systemdir.sh
fi

local allowed_commands_array=( command_backup.sh command_console.sh command_debug.sh command_details.sh command_unreal2_maps.sh command_ut99_maps.sh command_monitor.sh command_start.sh command_stop.sh update_check.sh command_validate.sh update_functions.sh command_email_test.sh )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${function_selfname}" ]; then
		check_logs.sh
	fi
done

local allowed_commands_array=( command_debug.sh command_start.sh command_stop.sh )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${function_selfname}" ]; then
		check_deps.sh
	fi
done

local allowed_commands_array=( command_debug.sh command_details.sh command_monitor.sh command_start.sh command_stop.sh )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${function_selfname}" ]; then
		check_ip.sh
	fi
done

local allowed_commands_array=( update_check.sh command_validate.sh )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${function_selfname}" ]; then
		if [ "${gamename}" == "Unreal Tournament 99" ]||[ "${gamename}" == "Unreal Tournament 2004" ]||[ "${gamename}" == "Mumble" ]||[ "${gamename}" == "Teamspeak 3" ]; then
			: # These servers do not require SteamCMD. Check is skipped.
		else
			check_steamcmd.sh
		fi
	fi
done

local allowed_commands_array=( command_console.sh command_start.sh )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${function_selfname}" ]; then
		check_tmux.sh
	fi
done

local allowed_commands_array=( command_console.sh command_debug.sh command_details.sh command_monitor.sh command_start.sh command_stop.sh )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${function_selfname}" ]; then
		check_config.sh
	fi
done