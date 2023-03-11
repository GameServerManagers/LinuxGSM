#!/bin/bash
# LinuxGSM update_vintagestory.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Handles updating of Vintage Story servers.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_vs_dl() {
	# Download and extract files to serverfiles
	fn_fetch_file "${remotebuildurl}" "" "" "" "${tmpdir}" "${remotebuildfilename}" "nochmodx" "norun" "force" "${remotebuildmd5}"
	fn_dl_extract "${tmpdir}" "${remotebuildfilename}" "${serverfiles}"
	fn_clear_tmp
}

fn_update_vs_localbuild() {
	# Gets local build info.
	fn_print_dots "Checking local build: ${remotelocation}"
	# Uses executable to get local build.
	cd "${executabledir}" || exit
	localbuild="$(${preexecutable} ${executable} --version | sed '/^[[:space:]]*$/d')"
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

fn_update_vs_remotebuild() {
	apiurl="http://api.vintagestory.at/stable-unstable.json"
	remotebuildresponse=$(curl -s "${apiurl}")
	if [ "${branch}" == "stable" ]; then
		remotebuildversion=$(echo -e "${remotebuildresponse}" | jq -r '[ to_entries[] ] | .[].key' | grep -Ev "\-rc|\-pre" | sort -r -V | head -1)
	else
		remotebuildversion=$(echo -e "${remotebuildresponse}" | jq -r '[ to_entries[] ] | .[].key' | grep -E "\-rc|\-pre" | sort -r -V | head -1)
	fi
	remotebuildfilename=$(echo -e "${remotebuildresponse}" | jq --arg remotebuildversion "${remotebuildversion}" -r '.[$remotebuildversion].server.filename')
	remotebuildurl=$(echo -e "${remotebuildresponse}" | jq --arg remotebuildversion "${remotebuildversion}" -r '.[$remotebuildversion].server.filename')
	remotebuildmd5=$(echo -e "${remotebuildresponse}" | jq --arg remotebuildversion "${remotebuildversion}" -r '.[$remotebuildversion].server.filename')

	if [ "${firstcommandname}" != "INSTALL" ]; then
		fn_print_dots "Checking remote build: ${remotelocation}"
		# Checks if remotebuildversion variable has been set.
		if [ -z "${remotebuildversion}" ] || [ "${remotebuildversion}" == "null" ]; then
			fn_print_fail "Checking remote build: ${remotelocation}"
			fn_script_log_fatal "Checking remote build"
			core_exit.sh
		else
			fn_print_ok "Checking remote build: ${remotelocation}"
			fn_script_log_pass "Checking remote build"
		fi
	else
		# Checks if remotebuild variable has been set.
		if [ -z "${remotebuildversion}" ] || [ "${remotebuildversion}" == "null" ]; then
			fn_print_failure "Unable to get remote build"
			fn_script_log_fatal "Unable to get remote build"
			core_exit.sh
		fi
	fi
}

fn_update_vs_compare() {
	fn_print_dots "Checking for update: ${remotelocation}"
	if [ "${localbuild}" != "${remotebuild}" ] || [ "${forceupdate}" == "1" ]; then
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		echo -en "\n"
		echo -e "Update available"
		echo -e "* Local build: ${red}${localbuild}${default}"
		echo -e "* Remote build: ${green}${remotebuild}${default}"
		if [ -n "${branch}" ]; then
			echo -e "* Branch: ${branch}"
		fi
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
				exitbypass=1
				fn_update_vs_dl
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
				fn_update_vs_dl
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
		if [ -n "${branch}" ]; then
			echo -e "* Branch: ${branch}"
		fi
		echo -en "\n"
		fn_script_log_info "No update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuild}"
		if [ -n "${branch}" ]; then
			fn_script_log_info "Branch: ${branch}"
		fi
	fi
}

# The location where the builds are checked and downloaded.
remotelocation="vintagestory.at"

if [ "${firstcommandname}" == "INSTALL" ]; then
	fn_update_vs_remotebuild
	fn_update_vs_dl
else
	fn_print_dots "Checking for update"
	fn_print_dots "Checking for update: ${remotelocation}"
	fn_script_log_info "Checking for update: ${remotelocation}"
	fn_update_vs_localbuild
	fn_update_vs_remotebuild
	fn_update_vs_compare
fi
