#!/bin/bash
# LinuxGSM command_ut99.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Handles updating of Unreal Tournament 99 servers.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_ut99_dl() {
	remotebuildurl=$(curl --connect-timeout 10 -sL "https://api.github.com/repos/OldUnreal/UnrealTournamentPatches/releases/latest" | jq -r '.assets[]|select(.browser_download_url | contains("Linux-amd64")) | .browser_download_url')
	remotebuildfilename=$(curl --connect-timeout 10 -sL "https://api.github.com/repos/OldUnreal/UnrealTournamentPatches/releases/latest" | jq -r '.assets[]|select(.browser_download_url | contains("Linux-amd64")) | .name')

	fn_fetch_file "${remotebuildurl}" "" "" "" "${tmpdir}" "${remotebuildfilename}" "" "norun" "noforce" "nohash"
	fn_dl_extract "${tmpdir}" "${remotebuildfilename}" "${serverfiles}"
	echo "${remotebuild}" > "${serverfiles}/build.txt"
}

fn_update_ut99_localbuild() {
	# Gets local build info.
	fn_print_dots "Checking local build: ${remotelocation}"
	# Uses build file to get local build.
	localbuild=$(head -n 1 "${serverfiles}/build.txt")
	if [ -z "${localbuild}" ]; then
		fn_print_error "Checking local build: ${remotelocation}: missing local build info"
		fn_script_log_error "Missing local build info"
		fn_script_log_error "Set localbuild to 0"
		localbuild="0"
	else
		fn_print_ok "Checking local build: ${remotelocation}"
		fn_script_log_pass "Checking local build"
	fi
}

fn_update_ut99_remotebuild() {
	# Gets remote build info.
	remotebuild=$(curl -s "https://api.github.com/repos/OldUnreal/UnrealTournamentPatches/releases/latest" | jq -r '.tag_name')
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
	fn_print_dots "Checking for update: ${remotelocation}"
	if [ "${localbuild}" != "${remotebuild}" ] || [ "${forceupdate}" == "1" ]; then
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		echo -en "\n"
		echo -e "Update available"
		echo -e "* Local build: ${red}${localbuild}${default}"
		echo -e "* Remote build: ${green}${remotebuild}${default}"
		echo -en "\n"
		fn_script_log_info "Update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuild}"
		fn_script_log_info "${localbuild} > ${remotebuild}"

		if [ "${commandname}" == "UPDATE" ]; then
			unset updateonstart
			check_status.sh
			# If server stopped.
			if [ "${status}" == "0" ]; then
				fn_update_ut99_dl
				if [ "${localbuild}" == "0" ]; then
					exitbypass=1
					command_start.sh
					fn_firstcommand_reset
					exitbypass=1
					sleep 5
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
			unset exitbypass
			date +%s > "${lockdir}/lastupdate.lock"
			alert="update"
		elif [ "${commandname}" == "CHECK-UPDATE" ]; then
			alert="check-update"
		fi
		alert.sh
	else
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		echo -en "\n"
		echo -e "No update available"
		echo -e "* Local build: ${green}${localbuild}${default}"
		echo -e "* Remote build: ${green}${remotebuild}${default}"
		echo -en "\n"
		fn_script_log_info "No update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuild}"
	fi
}

# The location where the builds are checked and downloaded.
remotelocation="github.com"

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
