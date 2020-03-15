#!/bin/bash
# LinuxGSM check.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Overall function for managing checks.
# Runs checks that will either halt on or fix an issue.

local modulename="CHECK"

# Every command that requires checks just references check.sh.
# check.sh selects which checks to run by using arrays.

if [ "${userinput}" != "install" ]&&[ "${userinput}" != "auto-install" ]&&[ "${userinput}" != "i" ]&&[ "${userinput}" != "ai" ]; then
	check_root.sh
fi

check_tmuxception.sh

if [ "$(whoami)" != "root" ]; then
	if [ "${function_selfname}" != "command_monitor.sh" ]; then
		check_permissions.sh
	fi
fi

if [ "${function_selfname}" != "command_install.sh" ]&&[ "${function_selfname}" != "command_update_functions.sh" ]&&[ "${function_selfname}" != "command_update_linuxgsm.sh" ]&&[ "${function_selfname}" != "command_details.sh" ]&&[ "${function_selfname}" != "command_postdetails.sh" ]; then
	check_system_dir.sh
fi

local allowed_commands_array=( command_start.sh command_debug.sh )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${function_selfname}" ]; then
		check_executable.sh
	fi
done

if [ "$(whoami)" != "root" ]; then
	local allowed_commands_array=( command_debug.sh command_start.sh command_install.sh )
	for allowed_command in "${allowed_commands_array[@]}"
	do
		if [ "${allowed_command}" == "${function_selfname}" ]; then
			check_glibc.sh
		fi
	done
fi

local allowed_commands_array=( command_backup.sh command_console.sh command_debug.sh command_details.sh command_unreal2_maps.sh command_fastdl.sh command_mods_install.sh command_mods_remove.sh command_mods_update.sh command_monitor.sh command_postdetails.sh command_restart.sh command_start.sh command_stop.sh command_test_alert.sh command_ts3_server_pass.sh command_update.sh command_update_functions.sh command_validate.sh command_wipe.sh command_unreal2_maps.sh command_ut99maps.sh)
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

local allowed_commands_array=( command_console.sh command_debug.sh command_monitor.sh command_start.sh command_stop.sh )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${function_selfname}" ]; then
		check_config.sh
	fi
done

local allowed_commands_array=( command_debug.sh command_details.sh command_postdetails.sh command_monitor.sh command_start.sh command_stop.sh command_dev_query_raw.sh )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${function_selfname}" ]; then
		if [ -z "${installflag}" ]; then
			check_ip.sh
		fi
	fi
done

local allowed_commands_array=( update_steamcmd.sh command_debug.sh command_start.sh command_validate.sh )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${function_selfname}" ]; then
		if [ "${appid}" ]; then
			check_steamcmd.sh
		fi
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
