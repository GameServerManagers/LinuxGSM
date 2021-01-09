#!/bin/bash
# LinuxGSM update_vintagestory.sh function
# Author: Christian Birk
# Website: https://linuxgsm.com
# Description: Handles updating of Vintage Story servers.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_vs_dl(){
	# get version info for download
	remotebuildresponse=$(curl -s "${apiurl}" | jq --arg version "${remotebuild}" '.[$version].server')
	remotebuildfile=$(echo -e "${remotebuildresponse}" | jq -r '.filename')
	remotebuildlink=$(echo -e "${remotebuildresponse}" | jq -r '.urls.cdn')
	remotebuildmd5=$(echo -e "${remotebuildresponse}" | jq -r '.md5')

	# Download and extract files to serverfiles
	fn_fetch_file "${remotebuildlink}" "" "" "" "${tmpdir}" "${remotebuildfile}" "nochmodx" "norun" "force" "${remotebuildmd5}"
	fn_dl_extract "${tmpdir}" "${remotebuildfile}" "${serverfiles}"
	fn_clear_tmp
}

fn_update_vs_localbuild(){
	# Gets local build info.
	fn_print_dots "Checking local build: ${remotelocation}"
	# Uses executable to find local build.
	cd "${executabledir}" || exit
	if [ -f "${executable}" ]; then
		localbuild=$(${preexecutable} ${executable} --version | sed '/^[[:space:]]*$/d')
		fn_print_ok "Checking local build: ${remotelocation}"
		fn_script_log_pass "Checking local build"
	else
		localbuild="0"
		fn_print_error "Checking local build: ${remotelocation}"
		fn_script_log_error "Checking local build"
	fi
}

fn_update_vs_remotebuild(){
	if [ "${branch}" == "stable" ]; then
		remotebuild=$(curl -s "${apiurl}" | jq -r '[ to_entries[] ] | .[].key' | grep -Ev "\-rc|\-pre" | sort -r -V | head -1)
	else
		remotebuild=$(curl -s "${apiurl}" | jq -r '[ to_entries[] ] | .[].key' | grep -E "\-rc|\-pre" | sort -r -V | head -1)
	fi

	if [ "${firstcommandname}" != "INSTALL" ]; then
		fn_print_dots "Checking remote build: ${remotelocation}"
		# Checks if remotebuild variable has been set.
		if [ -z "${remotebuild}" ]||[ "${remotebuild}" == "null" ]; then
			fn_print_fail "Checking remote build: ${remotelocation}"
			fn_script_log_fatal "Checking remote build"
			core_exit.sh
		else
			fn_print_ok "Checking remote build: ${remotelocation}"
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

fn_update_vs_compare(){
	# Removes dots so if statement can compare version numbers.
	fn_print_dots "Checking for update: ${remotelocation}"
	if [ "${localbuild}" != "${remotebuild}" ]||[ "${forceupdate}" == "1" ]; then
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

		unset updateonstart
		check_status.sh
		# If server stopped.
		if [ "${status}" == "0" ]; then
			exitbypass=1
			fn_update_vs_dl
			exitbypass=1
			command_start.sh
			exitbypass=1
			command_stop.sh
			fn_firstcommand_reset
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
apiurl="http://api.${remotelocation}/stable-unstable.json"
localversionfile="${datadir}/vintagestoryversion"

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
