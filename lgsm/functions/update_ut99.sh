#!/bin/bash
# LinuxGSM command_ut99.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Handles updating of Unreal Tournament 99 servers.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_ut99_dl() {
	remotebuildlink=$(curl --connect-timeout 10 -sL "https://api.github.com/repos/OldUnreal/UnrealTournamentPatches/releases/latest" | jq -r '.assets[]|select(.browser_download_url | contains("Linux-amd64")) | .browser_download_url')
	remotebuildfilename=$(curl --connect-timeout 10 -sL "https://api.github.com/repos/OldUnreal/UnrealTournamentPatches/releases/latest" | jq -r '.assets[]|select(.browser_download_url | contains("Linux-amd64")) | .name')

	fn_fetch_file "${remotebuildlink}" "${tmpdir}" "${remotebuildfilename}" "" "norun" "noforce" "nohash"
	fn_dl_extract "${tmpdir}" "${remotebuildfilename}" "${serverfiles}/${remotebuildfilename%.tar.bz2}"
	local exitcode=$?
	if [ "${exitcode}" == "0" ]; then
		fn_print_ok_eol_nl
		fn_script_log_pass "Copying to ${serverfiles}"
		fn_clear_tmp
		# put version number in version.txt
		echo "${remotebuild}" > "${serverfiles}/version.txt"
	else
		fn_print_fail_eol_nl
		fn_script_log_fatal "Copying to ${serverfiles}"
		core_exit.sh
	fi
}

fn_update_ut99_localbuild() {
	# Gets local build info.
	fn_print_dots "Checking local build: ${remotelocation}"
	# Uses log file to gather info.
	# Log is generated and cleared on startup but filled on shutdown.
	requirerestart=1
	localbuild=$(cat "${serverfiles}/version.txt" 2> /dev/null)
	if [ -z "${localbuild}" ]; then
		localbuild="0"
		fn_print_error "Checking local build: ${remotelocation}: waiting for local build: missing local build info"
		fn_script_log_error "Missing local build info"
		fn_script_log_error "Set localbuild to 0"
	else
		fn_print_ok "Checking local build: ${remotelocation}"
		fn_script_log_pass "Checking local build"
	fi
}

fn_update_ut99_remotebuild() {
	# Gets remote build info.
	remotebuild=$(curl --connect-timeout 10 -sL "https://api.github.com/repos/OldUnreal/UnrealTournamentPatches/releases/latest" | jq -r '.tag_name')
	if [ "${firstcommandname}" != "INSTALL" ]; then
		fn_print_dots "Checking remote build: ${remotelocation}"
		# Checks if remotebuild variable has been set.
		if [ -z "${remotebuild}" ] || [ "${remotebuild}" == "null" ]; then
			fn_print_fail "Checking remote build: ${remotelocation}"
			fn_script_log_fatal "Checking remote build"
			core_exit.sh
		else
			fn_print_ok "Checking remote build: ${remotelocation}"
			fn_script_log_pass "Checking remote build"
		fi
	else
		# Checks if remotebuild variable has been set.
		if [ -z "${remotebuild}" ] || [ "${remotebuild}" == "null" ]; then
			fn_print_failure "Unable to get remote build"
			fn_script_log_fatal "Unable to get remote build"
			core_exit.sh
		fi
	fi
}

fn_update_ut99_compare() {
	# Removes dots so if statement can compare version numbers.
	fn_print_dots "Checking for update: ${remotelocation}"
	localbuilddigit=$(echo -e "${localbuild}" | tr -cd '[:digit:]')
	remotebuilddigit=$(echo -e "${remotebuild}" | tr -cd '[:digit:]')
	if [ "${localbuilddigit}" -ne "${remotebuilddigit}" ] || [ "${forceupdate}" == "1" ]; then
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		echo -en "\n"
		echo -e "Update available"
		echo -e "* Local build: ${red}${localbuild} ${ut99arch}${default}"
		echo -e "* Remote build: ${green}${remotebuild} ${ut99arch}${default}"
		echo -en "\n"
		fn_script_log_info "Update available"
		fn_script_log_info "Local build: ${localbuild} ${ut99arch}"
		fn_script_log_info "Remote build: ${remotebuild} ${ut99arch}"
		fn_script_log_info "${localbuild} > ${remotebuild}"

		unset updateonstart
		check_status.sh
		# If server stopped.
		if [ "${status}" == "0" ]; then
			exitbypass=1
			fn_update_ut99_dl
			if [ "${requirerestart}" == "1" ]; then
				exitbypass=1
				command_start.sh
				fn_firstcommand_reset
				exitbypass=1
				command_stop.sh
				fn_firstcommand_reset
			fi
		# If server started.
		else
			fn_print_restart_warning
			exitbypass=1
			command_stop.sh
			fn_firstcommand_reset
			exitbypass=1
			fn_update_ut99_dl
			exitbypass=1
			command_start.sh
			fn_firstcommand_reset
		fi
		date +%s > "${lockdir}/lastupdate.lock"
		alert="update"
		alert.sh
	else
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		echo -en "\n"
		echo -e "No update available"
		echo -e "* Local build: ${green}${localbuild} ${ut99arch}${default}"
		echo -e "* Remote build: ${green}${remotebuild} ${ut99arch}${default}"
		echo -en "\n"
		fn_script_log_info "No update available"
		fn_script_log_info "Local build: ${localbuild} ${ut99arch}"
		fn_script_log_info "Remote build: ${remotebuild} ${ut99arch}"
	fi
}

# The location where the builds are checked and downloaded.
remotelocation="github.com"

# Game server architecture.
ut99arch="x64"

if [ "${firstcommandname}" == "INSTALL" ]; then
	fn_update_ut99_remotebuild
	fn_update_ut99_dl
else
	fn_print_dots "Checking for update"
	fn_print_dots "Checking for update: ${remotelocation}"
	fn_script_log_info "Checking for update: ${remotelocation}"
	fn_update_ut99_localbuild
	fn_update_ut99_remotebuild
	fn_update_ut99_compare
fi
