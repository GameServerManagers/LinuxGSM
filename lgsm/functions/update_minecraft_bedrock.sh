#!/bin/bash
# LinuxGSM update_minecraft_bedrock.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Handles updating of Minecraft Bedrock servers.

local commandname="UPDATE"
local commandaction="Update"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_minecraft_dl(){
	latestmcbuildurl=$(${curlpath} -s "https://www.minecraft.net/en-us/download/server/bedrock/" | grep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*zip')
	fn_fetch_file "${latestmcbuildurl}" "${tmpdir}" "bedrock_server.${remotebuild}.zip"
	echo -e "Extracting to ${serverfiles}...\c"
	if [ "${installer}" == "1" ]; then
		unzip "${tmpdir}/bedrock_server.${remotebuild}.zip" -x "server.properties" -d "${serverfiles}"
	else
		unzip -o "${tmpdir}/bedrock_server.${remotebuild}.zip" -x "permissions.json" "server.properties" "whitelist.json" -d "${serverfiles}"
	fi
	local exitcode=$?
	if [ "${exitcode}" == "0" ]; then
		fn_print_ok_eol_nl
		fn_script_log_pass "Extracting to ${serverfiles}"
		chmod u+x "${serverfiles}/bedrock_server"
		fn_clear_tmp
	else
		fn_print_fail_eol_nl
		fn_script_log_fatal "Extracting to ${serverfiles}"
		core_exit.sh
	fi
}

fn_update_minecraft_localbuild(){
	# Gets local build info.
	fn_print_dots "Checking for update: ${remotelocation}: checking local build"
	# Uses log file to gather info.
	# Log is generated and cleared on startup but filled on shutdown.
	local serverlog="${gamelogdir}/Dedicated_Server.txt"
	if [ ! -s "${serverlog}" ]; then
		fn_print_error "Checking for update: ${remotelocation}: checking local build"
		fn_print_error_nl "Checking for update: ${remotelocation}: checking local build: no or empty log file"
		fn_script_log_error "No log found or log is empty"
		fn_print_info_nl "Checking for update: ${remotelocation}: checking local build: forcing server restart"
		fn_script_log_info "Forcing server restart"

		check_status.sh
		if [ "${status}" != "0" ]; then
			exitbypass=1
			command_stop.sh
		else
			exitbypass=1
			command_start.sh
			sleep 3
			exitbypass=1
			command_stop.sh
		fi
	fi

	if [ -z "${localbuild}" ]; then
		localbuild=$(cat "${serverlog}" 2> /dev/null | grep Version | grep -Eo '[\.0-9]+$')
	fi

	if [ -z "${localbuild}" ]; then
		localbuild="0"
		fn_print_error "Checking for update: ${remotelocation}: waiting for local build: missing local build info"
		fn_script_log_error "Missing local build info"
		fn_script_log_error "Set localbuild to 0"
	else
		fn_print_ok "Checking for update: ${remotelocation}: checking local build"
		fn_script_log_pass "Checking local build"
	fi
}

fn_update_minecraft_remotebuild(){
	# Gets remote build info.
	remotebuild=$(${curlpath} -s "https://www.minecraft.net/en-us/download/server/bedrock/" | grep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*' | sed 's/.*\///' | grep -Eo "[.0-9]+[0-9]")
	if [ "${installer}" != "1" ]; then
		fn_print_dots "Checking for update: ${remotelocation}: checking remote build"
		# Checks if remotebuild variable has been set.
		if [ -z "${remotebuild}" ]||[ "${remotebuild}" == "null" ]; then
			fn_print_fail "Checking for update: ${remotelocation}: checking remote build"
			fn_script_log_fatal "Checking remote build"
			core_exit.sh
		else
			fn_print_ok "Checking for update: ${remotelocation}: checking remote build"
			fn_script_log_pass "Checking remote build"
		fi
	else
		# Checks if remotebuild variable has been set.
		if [ -z "${remotebuild}" ]||[ "${remotebuild}" == "null" ]; then
			fn_print_failure "Unable to get remote build"
			fn_script_log_fatal "Unable to get remote build"
			core_exit.sh
		fi
	fi
}

fn_update_minecraft_compare(){
	# Removes dots so if statement can compare version numbers.
	fn_print_dots "Checking for update: ${remotelocation}"
	localbuilddigit=$(echo -e "${localbuild}" | tr -cd '[:digit:]')
	remotebuilddigit=$(echo -e "${remotebuild}" | tr -cd '[:digit:]')
	if [ "${localbuilddigit}" -ne "${remotebuilddigit}" ]||[ "${forceupdate}" == "1" ]; then
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		echo -en "\n"
		echo -e "Update available"
		echo -e "* Local build: ${red}${localbuild}${default}"
		echo -e "* Remote build: ${green}${remotebuild}${default}"
		fn_script_log_info "Update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuild}"
		fn_script_log_info "${localbuild} > ${remotebuild}"
		fn_sleep_time
		echo -en "\n"
		echo -en "applying update.\r"
		sleep 1
		echo -en "applying update..\r"
		sleep 1
		echo -en "applying update...\r"
		sleep 1
		echo -en "\n"

		unset updateonstart

		check_status.sh
		# If server stopped.
		if [ "${status}" == "0" ]; then
			exitbypass=1
			fn_update_minecraft_dl
			exitbypass=1
			command_start.sh
			exitbypass=1
			command_stop.sh
		# If server started.
		else
			exitbypass=1
			command_stop.sh
			exitbypass=1
			fn_update_minecraft_dl
			exitbypass=1
			command_start.sh
		fi
		alert="update"
		alert.sh
	else
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		echo -en "\n"
		echo -e "No update available"
		echo -e "* Local build: ${green}${localbuild}${default}"
		echo -e "* Remote build: ${green}${remotebuild}${default}"
		fn_script_log_info "No update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuild}"

		# Start the server again if it was running before the update check.
		if [ "${initialstatus}" != "0" ]; then
			exitbypass=1
			command_start.sh
		fi
	fi
}

# The location where the builds are checked and downloaded.
remotelocation="minecraft.net"

if [ "${installer}" == "1" ]; then
	fn_update_minecraft_remotebuild
	fn_update_minecraft_dl
else
	check_status.sh
	initialstatus="${status}"
	fn_print_dots "Checking for update: ${remotelocation}"
	fn_script_log_info "Checking for update: ${remotelocation}"
	fn_update_minecraft_localbuild
	fn_update_minecraft_remotebuild
	fn_update_minecraft_compare
fi
