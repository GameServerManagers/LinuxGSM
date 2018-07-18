#!/bin/bash
# LinuxGSM update_minecraft.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Handles updating of Minecraft servers.

commandname="UPDATE"
commandaction="Update"
function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_dl(){
	fn_fetch_file "https://s3.amazonaws.com/Minecraft.Download/versions/${availablebuild}/minecraft_server.${availablebuild}.jar" "${tmpdir}" "minecraft_server.${availablebuild}.jar"
	echo -e "copying to ${serverfiles}...\c"
	fn_script_log "Copying to ${serverfiles}"
	cp "${tmpdir}/minecraft_server.${availablebuild}.jar" "${serverfiles}/minecraft_server.jar"
	local exitcode=$?
	if [ ${exitcode} -eq 0 ]; then
		fn_print_ok_eol_nl
	else
		fn_print_fail_eol_nl
	fi
}

fn_update_currentbuild(){
	# Gets current build info
	# Checks if current build info is available. If it fails, then a server restart will be forced to generate logs.
	if [ ! -f "${consolelogdir}/${servicename}-console.log" ]; then
		fn_print_error "Checking for update: mojang.com"
		sleep 0.5
		fn_print_error_nl "Checking for update: mojang.com: No logs with server version found"
		fn_script_log_error "Checking for update: mojang.com: No logs with server version found"
		sleep 0.5
		fn_print_info_nl "Checking for update: mojang.com: Forcing server restart"
		fn_script_log_info "Checking for update: mojang.com: Forcing server restart"
		sleep 0.5
		exitbypass=1
		command_stop.sh
		exitbypass=1
		command_start.sh
		sleep 0.5
		# Check again and exit on failure.
		if [ ! -f "${consolelogdir}/${servicename}-console.log" ]; then
			fn_print_fail_nl "Checking for update: mojang.com: Still No logs with server version found"
			fn_script_log_fatal "Checking for update: mojang.com: Still No logs with server version found"
			core_exit.sh
		fi
	fi

	# Get current build from logs
	currentbuild=$(cat "${serverfiles}/logs/latest.log" 2> /dev/null | grep version | grep -Eo '((\.)?[0-9]{1,3}){1,3}\.[0-9]{1,3}')
	if [ -z "${currentbuild}" ]; then
		fn_print_error_nl "Checking for update: mojang.com: Current build version not found"
		fn_script_log_error "Checking for update: mojang.com: Current build version not found"
		sleep 0.5
		fn_print_info_nl "Checking for update: mojang.com: Forcing server restart"
		fn_script_log_info "Checking for update: mojang.com: Forcing server restart"
		exitbypass=1
		command_stop.sh
		exitbypass=1
		command_start.sh
		currentbuild=$(cat "${serverfiles}/logs/latest.log" 2> /dev/null | grep version | grep -Eo '((\.)?[0-9]{1,3}){1,3}\.[0-9]{1,3}')
		if [ -z "${currentbuild}" ]; then
			fn_print_fail_nl "Checking for update: mojang.com: Current build version still not found"
			fn_script_log_fatal "Checking for update: mojang.com: Current build version still not found"
			core_exit.sh
		fi
	fi
}

fn_update_availablebuild(){
	# Gets latest build info.
	availablebuild=$(${curlpath} -s "https://launchermeta.mojang.com/mc/game/version_manifest.json" | sed -e 's/^.*"release":"\([^"]*\)".*$/\1/')
	# Checks if availablebuild variable has been set
	if [ -z "${availablebuild}" ]; then
		fn_print_fail "Checking for update: mojang.com"
		sleep 0.5
		fn_print_fail "Checking for update: mojang.com: Not returning version info"
		fn_script_log_fatal "Failure! Checking for update: mojang.com: Not returning version info"
		core_exit.sh
	elif [ "${installer}" == "1" ]; then
		:
	else
		fn_print_ok_nl "Checking for update: mojang.com"
		fn_script_log_pass "Checking for update: mojang.com"
		sleep 0.5
	fi
}

fn_update_compare(){
	# Removes dots so if can compare version numbers
	currentbuilddigit=$(echo "${currentbuild}" | tr -cd '[:digit:]')
	availablebuilddigit=$(echo "${availablebuild}" | tr -cd '[:digit:]')

	if [ "${currentbuilddigit}" -ne "${availablebuilddigit}" ]; then
		echo -e "\n"
		echo -e "Update available:"
		sleep 0.5
		echo -e "	Current build: ${red}${currentbuild}${default}"
		echo -e "	Available build: ${green}${availablebuild}${default}"
		echo -e ""
		sleep 0.5
		echo ""
		echo -en "Applying update.\r"
		sleep 1
		echo -en "Applying update..\r"
		sleep 1
		echo -en "Applying update...\r"
		sleep 1
		echo -en "\n"
		fn_script_log "Update available"
		fn_script_log "Current build: ${currentbuild}"
		fn_script_log "Available build: ${availablebuild}"
		fn_script_log "${currentbuild} > ${availablebuild}"

		unset updateonstart

		check_status.sh
		if [ "${status}" == "0" ]; then
			fn_update_dl
			exitbypass=1
			command_start.sh
			exitbypass=1
			command_stop.sh
		else
			exitbypass=1
			command_stop.sh
			fn_update_dl
			exitbypass=1
			command_start.sh
		fi
		alert="update"
		alert.sh
	else
		echo -e "\n"
		echo -e "No update available:"
		echo -e "	Current version: ${green}${currentbuild}${default}"
		echo -e "	Available version: ${green}${availablebuild}${default}"
		echo -e ""
		fn_print_ok_nl "No update available"
		fn_script_log_info "Current build: ${currentbuild}"
		fn_script_log_info "Available build: ${availablebuild}"
	fi
}

if [ "${installer}" == "1" ]; then
	fn_update_availablebuild
	fn_update_dl
else
	# Checks for server update from mojang.com
	fn_print_dots "Checking for update: mojang.com"
	fn_script_log_info "Checking for update: mojang.com"
	sleep 0.5
	fn_update_currentbuild
	fn_update_availablebuild
	fn_update_compare
fi
