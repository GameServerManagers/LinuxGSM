#!/bin/bash
# LinuxGSM update_minecraft.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Handles updating of Minecraft servers.

local commandname="UPDATE"
local commandaction="Update"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_minecraft_dl(){
	latestmcreleaselink=$(${curlpath} -s "https://launchermeta.mojang.com/mc/game/version_manifest.json" | jq -r '.latest.release as $latest | .versions[] | select(.id == $latest) | .url')
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
	# Uses log file to gather info.
	# Gives time for log file to generate.
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

			if [ "${totalseconds}" -gt "120" ]; then
				localbuild="0"
				fn_print_error "Checking for update: ${remotelocation}: waiting for log file: missing log file"
				fn_script_log_error "Missing log file"
				fn_script_log_error "Set localbuild to 0"
				sleep 0.5
			fi

			totalseconds=$((totalseconds + 1))
		done
	fi

	if [ -z "${localbuild}" ]; then
		localbuild=$(cat "${serverfiles}/logs/latest.log" 2> /dev/null | grep version | grep -Eo '((\.)?[0-9]{1,3}){1,3}\.[0-9]{1,3}')
	fi

	if [ -z "${localbuild}" ]; then
		# Gives time for var to generate.
		totalseconds=0
		for seconds in {1..120}; do
			fn_print_info "Checking for update: ${remotelocation}: checking local build: waiting for local build: ${totalseconds}"
			if [ -z "${loopignore}" ]; then
				loopignore=1
				fn_script_log_info "Waiting for local build to generate"
			fi
			localbuild=$(cat "${serverfiles}/logs/latest.log" 2> /dev/null | grep version | grep -Eo '((\.)?[0-9]{1,3}){1,3}\.[0-9]{1,3}')
			if [ "${localbuild}" ]||[ "${seconds}" == "120" ]; then
				break
			fi
			sleep 1
			totalseconds=$((totalseconds + 1))
		done
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
	sleep 0.5
}

fn_update_minecraft_remotebuild(){
	# Gets remote build info.
	remotebuild=$(${curlpath} -s "https://launchermeta.${remotelocation}/mc/game/version_manifest.json" | jq -r '.latest.release')
	if [ "${installer}" != "1" ]; then
		fn_print_dots "Checking for update: ${remotelocation}: checking remote build"
		sleep 0.5
		# Checks if remotebuild variable has been set.
		if [ -z "${remotebuild}" ]||[ "${remotebuild}" == "null" ]; then
			fn_print_fail "Checking for update: ${remotelocation}: checking remote build"
			fn_script_log_fatal "Checking remote build"
			core_exit.sh
		else
			fn_print_ok "Checking for update: ${remotelocation}: checking remote build"
			fn_script_log_pass "Checking remote build"
			sleep 0.5
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
	sleep 0.5
	localbuilddigit=$(echo "${localbuild}" | tr -cd '[:digit:]')
	remotebuilddigit=$(echo "${remotebuild}" | tr -cd '[:digit:]')
	if [ "${localbuilddigit}" -ne "${remotebuilddigit}" ]||[ "${forceupdate}" == "1" ]; then
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
