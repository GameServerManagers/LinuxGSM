#!/bin/bash
# LinuxGSM check.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Overall function for managing checks.
# Runs checks that will either halt on or fix an issue.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Every command that requires checks just references check.sh.
# check.sh selects which checks to run by using arrays.

if [ "${commandname}" != "INSTALL" ]; then
	check_root.sh
fi

if [ "${commandname}" != "UPDATE-LGSM" ]; then
	check_version.sh
fi

check_tmuxception.sh

if [ "$(whoami)" != "root" ]; then
	if [ "${commandname}" != "MONITOR" ]; then
		check_permissions.sh
	fi
fi

if [ "${commandname}" != "INSTALL" ]&&[ "${commandname}" != "UPDATE-LGSM" ]&&[ "${commandname}" != "DETAILS" ]&&[ "${commandname}" != "POST-DETAILS" ]; then
	check_system_dir.sh
fi

allowed_commands_array=( START DEBUG )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${commandname}" ]; then
		check_executable.sh
	fi
done

if [ "$(whoami)" != "root" ]; then
	allowed_commands_array=( DEBUG START INSTALL )
	for allowed_command in "${allowed_commands_array[@]}"
	do
		if [ "${allowed_command}" == "${commandname}" ]; then
			check_glibc.sh
		fi
	done
fi

allowed_commands_array=( BACKUP CONSOLE DEBUG DETAILS MAP-COMPRESSOR FASTDL MODS-INSTALL MODS-REMOVE MODS-UPDATE MONITOR POST-DETAILS RESTART START STOP TEST-ALERT CHANGE-PASSWORD UPDATE UPDATE-LGSM VALIDATE WIPW )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${commandname}" ]; then
		check_logs.sh
	fi
done

allowed_commands_array=( DEBUG START STOP )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${commandname}" ]; then
		check_deps.sh
	fi
done

allowed_commands_array=( CONSOLE DEBUG MONITOR START STOP )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${commandname}" ]; then
		check_config.sh
	fi
done

allowed_commands_array=( DEBUG DETAILS POST_DETAILS MONITOR START STOP DEV-QUERY-RAW )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${commandname}" ]; then
		if [ -z "${installflag}" ]; then
			check_ip.sh
		fi
	fi
done

allowed_commands_array=( DEBUG START VALIDATE )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${commandname}" ]; then
		if [ "${appid}" ]; then
			check_steamcmd.sh
		fi
	fi
done

allowed_commands_array=( DETAILS MONITOR START STOP CHANGE-PASSWORD UPDATE VALIDATE )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${commandname}" ]; then
		check_status.sh
	fi
done

allowed_commands_array=( DEBUG START INSTALL )
for allowed_command in "${allowed_commands_array[@]}"
do
	if [ "${allowed_command}" == "${commandname}" ]; then
		check_system_requirements.sh
	fi
done
