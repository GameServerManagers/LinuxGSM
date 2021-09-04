#!/bin/bash
# LinuxGSM update_jk2.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Handles updating of jk2 servers.

local commandname="UPDATE"
local commandaction="Update"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_jk2_dl(){
	fn_fetch_file "https://github.com/mvdevs/jk2mv/releases/download/${remotebuild}/jk2mv-v${remotebuild}-dedicated.zip" "" "" "" "${tmpdir}" "jk2mv-${remotebuild}-dedicated.zip" "" "norun" "noforce" "nomd5"
	fn_dl_extract "${tmpdir}" "jk2mv-${remotebuild}-dedicated.zip" "${tmpdir}/jk2mv-v${remotebuild}-dedicated"
	echo -e "copying to ${serverfiles}...\c"
	cp -R "${tmpdir}/jk2mv-v${remotebuild}-dedicated/linux-amd64/jk2mvded"* "${serverfiles}/GameData"
	local exitcode=$?
	if [ "${exitcode}" == "0" ]; then
		fn_print_ok_eol_nl
		fn_script_log_pass "Copying to ${serverfiles}"
		fn_clear_tmp
	else
		fn_print_fail_eol_nl
		fn_script_log_fatal "Copying to ${serverfiles}"
		core_exit.sh
	fi
}

fn_update_jk2_localbuild(){
	# Gets local build info.
	fn_print_dots "Checking local build: ${remotelocation}"
	# Uses log file to gather info.
	# Log is generated and cleared on startup but filled on shutdown.
	localbuild=$(grep "\"version\"" "${consolelogdir}"/* 2>/dev/null | sed 's/.*://' | awk '{print $1}' | head -n 1)
	if [ -z "${localbuild}" ]; then
		fn_print_error "Checking local build: ${remotelocation}"
		fn_print_error_nl "Checking local build: ${remotelocation}: no log files containing version info"
		fn_print_info_nl "Checking local build: ${remotelocation}: forcing server restart"
		fn_script_log_error "No log files containing version info"
		fn_script_log_info "Forcing server restart"

		check_status.sh
		# If server stopped.
		if [ "${status}" == "0" ]; then
			exitbypass=1
			command_start.sh
			fn_firstcommand_reset
			sleep 3
			exitbypass=1
			command_stop.sh
			fn_firstcommand_reset
		# If server started.
		else
			exitbypass=1
			command_stop.sh
			fn_firstcommand_reset
		fi
	fi

	if [ -z "${localbuild}" ]; then
		localbuild=$(grep Version "$(ls -tr "${consolelogdir}"/* 2>/dev/null)" | tail -1 | sed 's/.*Version //')
	fi

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

fn_update_jk2_remotebuild(){
	# Gets remote build info.
	remotebuild=$(curl -s "https://api.github.com/repos/mvdevs/jk2mv/releases/latest" | grep dedicated.zip | tail -1 | awk -F"/" '{ print $8 }')
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

fn_update_jk2_compare(){
	# Removes dots so if statement can compare version numbers.
	fn_print_dots "Checking for update: ${remotelocation}"
	localbuilddigit=$(echo -e "${localbuild}" | tr -cd '[:digit:]')
	remotebuilddigit=$(echo -e "${remotebuild}" | tr -cd '[:digit:]')
	if [ "${localbuilddigit}" -ne "${remotebuilddigit}" ]||[ "${forceupdate}" == "1" ]; then
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		echo -en "\n"
		echo -e "Update available"
		echo -e "* Local build: ${red}${localbuild} ${jk2arch}${default}"
		echo -e "* Remote build: ${green}${remotebuild} ${jk2arch}${default}"
		echo -en "\n"
		fn_script_log_info "Update available"
		fn_script_log_info "Local build: ${localbuild} ${jk2arch}"
		fn_script_log_info "Remote build: ${remotebuild} ${jk2arch}"
		fn_script_log_info "${localbuild} > ${remotebuild}"

		unset updateonstart
		check_status.sh
		# If server stopped.
		if [ "${status}" == "0" ]; then
			exitbypass=1
			fn_update_jk2_dl
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
			fn_update_jk2_dl
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
		echo -e "* Local build: ${green}${localbuild} ${jk2arch}${default}"
		echo -e "* Remote build: ${green}${remotebuild} ${jk2arch}${default}"
		echo -en "\n"
		fn_script_log_info "No update available"
		fn_script_log_info "Local build: ${localbuild} ${jk2arch}"
		fn_script_log_info "Remote build: ${remotebuild} ${jk2arch}"
	fi
}

# The location where the builds are checked and downloaded.
remotelocation="jk2mv.org"

# Game server architecture.
jk2arch="x64"

if [ "${firstcommandname}" == "INSTALL" ]; then
	fn_update_jk2_remotebuild
	fn_update_jk2_dl
else
	update_steamcmd.sh
	fn_print_dots "Checking for update"
	fn_print_dots "Checking for update: ${remotelocation}"
	fn_script_log_info "Checking for update: ${remotelocation}"
	fn_update_jk2_localbuild
	fn_update_jk2_remotebuild
	fn_update_jk2_compare
fi
