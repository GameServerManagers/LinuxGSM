#!/bin/bash
# LinuxGSM update_minecraft.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Handles updating of Minecraft servers.

local commandname="UPDATE"
local commandaction="Update"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_minecraft_dl(){
	latestmcreleaselink=$(${curlpath} -s "https://launchermeta.${remotelocation}/mc/game/version_manifest.json" | jq -r '.latest.release as $latest | .versions[] | select(.id == $latest) | .url')
	latestmcbuildurl=$(${curlpath} -s "${latestmcreleaselink}" | jq -r '.downloads.server.url')
	fn_fetch_file "${latestmcbuildurl}" "${tmpdir}" "minecraft_server.${remotebuild}.jar"
	echo -e "copying to ${serverfiles}...\c"
	cp "${tmpdir}/minecraft_server.${remotebuild}.jar" "${serverfiles}/minecraft_server.jar"
	local exitcode=$?
	if [ "${exitcode}" == "0" ]; then
		fn_print_ok_eol_nl
		fn_script_log_pass "Copying to ${serverfiles}"
		chmod u+x "${serverfiles}/minecraft_server.jar"
		fn_clear_tmp
	else
		fn_print_fail_eol_nl
		fn_script_log_fatal "Copying to ${serverfiles}"
		core_exit.sh
	fi
}

fn_update_minecraft_localbuild(){
	# Gets local build info.
	fn_print_dots "Checking for update: ${remotelocation}: checking local build"
	sleep 0.5
	# Uses log files to find local build.
	if [ ! -f "${serverfiles}/logs/latest.log" ]; then
		fn_print_error "Checking for update: ${remotelocation}: checking local build"
		sleep 0.5
		fn_print_error_nl "Checking for update: ${remotelocation}: checking local build: no log files"
		fn_script_log_error "No log file found"
		sleep 0.5
		fn_print_info_nl "Checking for update: ${remotelocation}: checking local build: forcing server restart"
		fn_script_log_info "Forcing server restart"
		sleep 0.5
		exitbypass=1
		command_stop.sh
		exitbypass=1
		command_start.sh
		totalseconds=0
		# Check again, allow time to generate logs.
		while [ ! -f "${serverfiles}/logs/latest.log" ]; do
			sleep 1
			fn_print_info "Checking for update: ${remotelocation}: checking local build: waiting for log file: ${totalseconds}"
			if [ -v "${loopignore}" ]; then
				loopignore=1
				fn_script_log_info "Waiting for log file to generate"
			fi

			if [ "${totalseconds}" >= "120" ]; then
				localbuild="0"
				fn_print_error "Checking for update: ${remotelocation}: waiting for log file: missing log file"
				fn_script_log_error "Missing log file"
				fn_script_log_error "Set localbuild to 0"
				sleep 0.5
			fi
			
			totalseconds=$((totalseconds + 1))
		done
		sleep 5
	fi

	if [ -f "${serverfiles}/logs/latest.log" ]; then
		# Get local build from logs.
		localbuild=$(cat "${serverfiles}/logs/latest.log" 2> /dev/null | grep version | grep -Eo '((\.)?[0-9]{1,3}){1,3}\.[0-9]{1,3}')
		if [ -z "${localbuild}" ]; then
			fn_print_error_nl "Checking for update: ${remotelocation}: checking local build: local build not found"
			fn_script_log_error "Local build not found"
			sleep 0.5
			fn_print_info_nl "Checking for update: ${remotelocation}: checking local build: forcing server restart"
			fn_script_log_info "Forcing server restart"
			exitbypass=1
			command_stop.sh
			exitbypass=1
			command_start.sh
			# Check again, allow time to generate logs.
			while [ ! -f "${serverfiles}/logs/latest.log" ]; do
				sleep 1
				fn_print_info "Checking for update: ${remotelocation}: checking local build: waiting for log file: ${totalseconds}"
				if [ -v "${loopignore}" ]; then
					loopignore=1
					fn_script_log_info "Waiting for log file to generate"
				fi

				if [ "${totalseconds}" >= "120" ]; then
					localbuild="0"
					fn_print_error "Checking for update: ${remotelocation}: waiting for log file: missing log file"
					fn_script_log_error "Missing log file"
					fn_script_log_error "Set localbuild to 0"
					sleep 0.5
				fi
				
				totalseconds=$((totalseconds + 1))
			done
			sleep 5
			localbuild=$(cat "${serverfiles}/logs/latest.log" 2> /dev/null | grep version | grep -Eo '((\.)?[0-9]{1,3}){1,3}\.[0-9]{1,3}')
			if [ -z "${localbuild}" ]; then
				localbuild="0"
				fn_print_error "Checking for update: ${remotelocation}: waiting for log file: local build not found"
				fn_script_log_error "Missing log file"
				fn_script_log_error "Set localbuild to 0"
				sleep 0.5
			fi
		fi
		fn_print_ok "Checking for update: ${remotelocation}: checking local build"
		sleep 0.5
	fi
}

fn_update_minecraft_remotebuild(){
	# Gets remote build info.
	fn_print_dots "Checking for update: ${remotelocation}: checking remote build"
	sleep 0.5
	remotebuild=$(${curlpath} -s "https://launchermeta.${remotelocation}/mc/game/version_manifest.json" | jq -r '.latest.release')
	# Checks if remotebuild variable has been set.
	if [ -v "${remotebuild}" ]||[ "${remotebuild}" == "null" ]; then
		fn_print_fail "Checking for update: ${remotelocation}: checking remote build"
		fn_script_log_fatal "Checking remote build"
		core_exit.sh
	elif [ "${installer}" == "1" ]; then
		:
	else
		fn_print_ok "Checking for update: ${remotelocation}: checking remote build"
		fn_script_log_pass "Checking remote build"
	fi
	sleep 0.5
}

fn_update_minecraft_compare(){
	# Removes dots so if statement can compare version numbers.
	fn_print_dots "Checking for update: ${remotelocation}"
	localbuilddigit=$(echo "${localbuild}" | tr -cd '[:digit:]')
	remotebuilddigit=$(echo "${remotebuild}" | tr -cd '[:digit:]')
	sleep 0.5
	if [ "${localbuilddigit}" -ne "${remotebuilddigit}" ]; then
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		sleep 0.5
		echo -en "\n"
		echo -e "Update available"
		echo -e "* Local build: ${red}${localbuild}${default}"
		echo -e "* Remote build: ${green}${remotebuild}${default}"
		fn_script_log_info "Update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuild}"
		fn_script_log_info "${localbuild} > ${remotebuild}"
		sleep 0.5
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
			fn_update_factorio_dl
			exitbypass=1
			command_start.sh
			exitbypass=1
			command_stop.sh
		# If server started.
		else
			exitbypass=1
			command_stop.sh
			exitbypass=1
			fn_update_factorio_dl
			exitbypass=1
			command_start.sh
		fi
		alert="update"
		alert.sh
	else
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		sleep 0.5
		echo -en "\n"
		echo -e "No update available"
		echo -e "* Local build: ${green}${localbuild}${default}"
		echo -e "* Remote build: ${green}${remotebuild}${default}"
		fn_script_log_info "No update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuild}"
	fi
}

# The location where the builds are checked and downloaded.
remotelocation="mojang.com"

if [ "${installer}" == "1" ]; then
	fn_update_minecraft_remotebuild
	fn_update_minecraft_dl
else
	fn_print_dots "Checking for update: ${remotelocation}"
	fn_script_log_info "Checking for update: ${remotelocation}"
	sleep 0.5
	fn_update_minecraft_localbuild
	fn_update_minecraft_remotebuild
	fn_update_minecraft_compare
fi
