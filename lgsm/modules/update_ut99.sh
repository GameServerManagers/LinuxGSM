#!/bin/bash
# LinuxGSM command_ut99.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Handles updating of Unreal Tournament 99 servers.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_dl() {
	# Download and extract files to serverfiles.
	fn_fetch_file "${remotebuildurl}" "" "" "" "${tmpdir}" "${remotebuildfilename}" "nochmodx" "norun" "force" "nohash"
	fn_dl_extract "${tmpdir}" "${remotebuildfilename}" "${serverfiles}"
	echo "${remotebuild}" > "${serverfiles}/build.txt"
	fn_clear_tmp
}

fn_update_localbuild() {
	# Gets local build info.
	fn_print_dots "Checking local build: ${remotelocation}"
	# Uses build file to get local build.
	localbuild=$(head -n 1 "${serverfiles}/build.txt" 2> /dev/null)
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

fn_update_remotebuild() {
	# Gets remote build info.
	apiurl="https://api.github.com/repos/OldUnreal/UnrealTournamentPatches/releases/latest"
	local attempt
	for attempt in 1 2 3; do
		remotebuildresponse=$(curl --connect-timeout 10 --max-time 30 --fail --silent --show-error --location "${apiurl}") || remotebuildresponse=""
		remotebuild=$(echo "${remotebuildresponse}" | jq -er 'select((.tag_name | type) == "string" and (.tag_name | length) > 0) | .tag_name' 2> /dev/null) || remotebuild=""
		remotebuildasset=$(echo "${remotebuildresponse}" | jq -cer '[.assets[]? | select((.browser_download_url | type) == "string" and (.browser_download_url | contains("Linux-amd64")))] | select(length == 1) | .[0]' 2> /dev/null) || remotebuildasset=""
		remotebuildfilename=$(echo "${remotebuildasset}" | jq -er 'select((.name | type) == "string" and (.name | length) > 0) | .name' 2> /dev/null) || remotebuildfilename=""
		remotebuildurl=$(echo "${remotebuildasset}" | jq -er 'select((.browser_download_url | type) == "string" and (.browser_download_url | length) > 0) | .browser_download_url' 2> /dev/null) || remotebuildurl=""
		if [ -n "${remotebuild}" ] && [ -n "${remotebuildfilename}" ] && [ -n "${remotebuildurl}" ]; then
			break
		fi
		if [ "${attempt}" -lt 3 ]; then
			sleep 2
		fi
	done

	if [ "${firstcommandname}" != "INSTALL" ]; then
		fn_print_dots "Checking remote build: ${remotelocation}"
		# Checks if remotebuild variable has been set.
		if [ -z "${remotebuild}" ] || [ -z "${remotebuildfilename}" ] || [ -z "${remotebuildurl}" ]; then
			fn_print_fail "Checking remote build: ${remotelocation}"
			fn_script_log_fail "Checking remote build"
			core_exit.sh
		else
			fn_print_ok "Checking remote build: ${remotelocation}"
			fn_script_log_pass "Checking remote build"
		fi
	else
		# Checks if remotebuild variable has been set.
		if [ -z "${remotebuild}" ] || [ -z "${remotebuildfilename}" ] || [ -z "${remotebuildurl}" ]; then
			fn_print_failure "Unable to get remote build"
			fn_script_log_fail "Unable to get remote build"
			core_exit.sh
		fi
	fi
}

fn_update_compare() {
	fn_print_dots "Checking for update: ${remotelocation}"
	# Update has been found or force update.
	if [ "${localbuild}" != "${remotebuild}" ] || [ "${forceupdate}" == "1" ]; then
		# Create update lockfile.
		date '+%s' > "${lockdir:?}/update.lock"
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		fn_print "\n"
		fn_print_nl "${bold}${underline}Update${default} available"
		fn_print_nl "* Local build: ${red}${localbuild}${default}"
		fn_print_nl "* Remote build: ${green}${remotebuild}${default}"
		if [ -n "${branch}" ]; then
			fn_print_nl "* Branch: ${branch}"
		fi
		if [ -f "${rootdir}/.dev-debug" ]; then
			fn_print_nl "Remote build info"
			fn_print_nl "* apiurl: ${apiurl}"
			fn_print_nl "* remotebuildfilename: ${remotebuildfilename}"
			fn_print_nl "* remotebuildurl: ${remotebuildurl}"
			fn_print_nl "* remotebuild: ${remotebuild}"
		fi
		fn_print "\n"
		fn_script_log_info "Update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuild}"
		if [ -n "${branch}" ]; then
			fn_script_log_info "Branch: ${branch}"
		fi
		fn_script_log_info "${localbuild} > ${remotebuild}"

		if [ "${commandname}" == "UPDATE" ]; then
			unset updateonstart
			fn_update_apply fn_update_dl
			if [ "${updatestatus}" == "0" ] && [ "${localbuild}" == "0" ]; then
				exitbypass=1
				command_start.sh
				fn_firstcommand_reset
				exitbypass=1
				fn_sleep_time_5
				command_stop.sh
				fn_firstcommand_reset
			fi
			unset exitbypass
			alert="update"
		elif [ "${commandname}" == "CHECK-UPDATE" ]; then
			alert="check-update"
		fi
		alert.sh
	else
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		fn_print "\n"
		fn_print_nl "${bold}${underline}No update${default} available"
		fn_print_nl "* Local build: ${green}${localbuild}${default}"
		fn_print_nl "* Remote build: ${green}${remotebuild}${default}"
		if [ -n "${branch}" ]; then
			fn_print_nl "* Branch: ${branch}"
		fi
		fn_print "\n"
		fn_script_log_info "No update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuild}"
		if [ -n "${branch}" ]; then
			fn_script_log_info "Branch: ${branch}"
		fi
		if [ -f "${rootdir}/.dev-debug" ]; then
			fn_print_nl "Remote build info"
			fn_print_nl "* apiurl: ${apiurl}"
			fn_print_nl "* remotebuildfilename: ${remotebuildfilename}"
			fn_print_nl "* remotebuildurl: ${remotebuildurl}"
			fn_print_nl "* remotebuild: ${remotebuild}"
		fi
	fi
}

# The location where the builds are checked and downloaded.
remotelocation="github.com"

if [ "${firstcommandname}" == "INSTALL" ]; then
	fn_update_remotebuild
	fn_update_dl
else
	fn_print_dots "Checking for update"
	fn_print_dots "Checking for update: ${remotelocation}"
	fn_script_log_info "Checking for update: ${remotelocation}"
	fn_update_localbuild
	fn_update_remotebuild
	fn_update_compare
fi
