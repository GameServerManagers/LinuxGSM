#!/bin/bash
# LinuxGSM update_waterfall.sh function
# Author: Duval Lucas
# Website: https://linuxgsm.com
# Description: Handles updating of Waterfall servers.

local commandname="UPDATE"
local commandaction="Update"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_wf_dl(){
	fn_fetch_file "https://${remotelocation}/api/v1/waterfall/${waterfall_version}/latest/download" "${tmpdir}" "waterfall.${remotebuild}.jar"
	echo -e "copying to ${serverfiles}...\c"
	cp "${tmpdir}/waterfall.${remotebuild}.jar" "${serverfiles}/waterfall.jar"
	local exitcode=$?
	if [ "${exitcode}" == "0" ]; then
		fn_print_ok_eol_nl
		fn_script_log_pass "Copying to ${serverfiles}"
		chmod u+x "${serverfiles}/waterfall.jar"
		echo "${remotebuild}" > "${configdirserver}/waterfall_localbuild.cfg"
		fn_clear_tmp
	else
		fn_print_fail_eol_nl
		fn_script_log_fatal "Copying to ${serverfiles}"
		core_exit.sh
	fi
}

fn_update_wf_localbuild(){
	# Gets local build info.
	fn_print_dots "Checking for update: ${remotelocation}: checking local build"
	sleep 0.5

	if [ ! -f "${configdirserver}/paper_localbuild.cfg" ]; then
		fn_print_error "Checking for update: ${remotelocation}: checking local build"
		sleep 0.5
		fn_print_error_nl "Checking for update: ${remotelocation}: checking local build: no local build files"
		fn_script_log_error "No local build file found"
		sleep 0.5
		fn_print_info_nl "Checking for update: ${remotelocation}: checking local build: forcing server restart"
	else
		localbuild=$(head -n 1 "${configdirserver}/waterfall_localbuild.cfg")
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

fn_update_wf_remotebuild(){
	# Gets remote build info.
	remotebuild=$(${curlpath} -s "https://${remotelocation}/api/v1/waterfall/${waterfall_version}/latest" | jq -r '.build')
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

fn_update_wf_compare(){
	fn_print_dots "Checking for update: ${remotelocation}"
	sleep 0.5
	if [ "${localbuild}" -ne "${remotebuild}" ]||[ "${forceupdate}" == "1" ]; then
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
			fn_update_wf_dl
			exitbypass=1
			command_start.sh
			exitbypass=1
			command_stop.sh
		# If server started.
		else
			exitbypass=1
			command_stop.sh
			exitbypass=1
			fn_update_wf_dl
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
remotelocation="papermc.io"
# The version of Waterfall the user want
waterfall_version=$(head -n 1 "${configdirserver}/waterfall_version.cfg")

if [ -z "${waterfall_version}" ]; then
	fn_print_error "No Waterfall version found"
	fn_script_log_error "No Waterfall version found"
	core_exit.sh
fi

if [ "${installer}" == "1" ]; then
	fn_update_wf_remotebuild
	fn_update_wf_dl
else
	fn_print_dots "Checking for update: ${remotelocation}"
	fn_script_log_info "Checking for update: ${remotelocation}"
	sleep 0.5
	fn_update_wf_localbuild
	fn_update_wf_remotebuild
	fn_update_wf_compare
fi
