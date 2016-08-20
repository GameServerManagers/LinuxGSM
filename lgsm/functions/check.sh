#!/bin/bash
# LGSM check.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Overall function for managing checks.
# Runs checks that will either halt on or fix an issue.

local commandname="CHECK"

# Every command that requires checks just references check.sh
# check.sh selects which checks to run by using arrays

check_root.sh
check_permissions.sh

if [ "${function_selfname}" != "command_install.sh" ]&&[ "${function_selfname}" != "command_update_functions.sh" ]; then
	check_system_dir.sh
fi

local allowed_commands_array=( command_debug.sh command_start.sh command_install.sh )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${function_selfname}" ]; then
		check_glibc.sh
	fi
done

local allowed_commands_array=( command_backup.sh command_console.sh command_debug.sh command_details.sh command_unreal2_maps.sh command_ut99_maps.sh command_monitor.sh command_start.sh command_stop.sh update_check.sh command_validate.sh command_update_functions.sh command_email_test.sh )
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

local allowed_commands_array=( update_steamcmd.sh command_debug.sh command_start.sh command_validate.sh )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${function_selfname}" ]; then
		if [ -n "${appid}" ]; then
			check_steamcmd.sh
		fi
	fi
done

local allowed_commands_array=( command_console.sh command_debug.sh command_details.sh command_monitor.sh command_start.sh command_stop.sh )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${function_selfname}" ]; then
		check_config.sh
	fi
done

local allowed_commands_array=( command_details.sh command_monitor.sh command_start.sh command_stop.sh command_ts3_server_pass.sh command_update.sh command_details.sh command_validate.sh )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${function_selfname}" ]; then
		check_status.sh
	fi
done

local allowed_commands_array=( command_debug.sh command_start.sh command_install.sh )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${function_selfname}" ]; then
		check_system_requirements.sh
	fi
done
