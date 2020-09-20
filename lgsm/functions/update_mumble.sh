#!/bin/bash
# LinuxGSM update_mumble.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Handles updating of Mumble servers.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_mumble_dl(){
	fn_fetch_file "https://github.com/mumble-voip/mumble/releases/download/${remotebuild}/murmur-static_${mumblearch}-${remotebuild}.tar.bz2" "" "" "" "${tmpdir}" "murmur-static_${mumblearch}-${remotebuild}.tar.bz2" "" "norun" "noforce" "nomd5"
	fn_dl_extract "${tmpdir}" "murmur-static_${mumblearch}-${remotebuild}.tar.bz2" "${tmpdir}"
	echo -e "copying to ${serverfiles}...\c"
	cp -R "${tmpdir}/murmur-static_${mumblearch}-${remotebuild}/"* "${serverfiles}"
	local exitcode=$?
	if [ "${exitcode}" == "0" ]; then
		fn_print_ok_eol_nl
		fn_script_log_pass "Copying to ${serverfiles}"
		fn_clear_tmp
	else
		fn_print_fail_eol_nl
		fn_script_log_fatal "Copying to ${serverfiles}"
		fn_clear_tmp
		core_exit.sh
	fi
}

fn_update_mumble_localbuild(){
	# Gets local build info.
	fn_print_dots "Checking local build: ${remotelocation}"
	# Uses executable to find local build.
	cd "${executabledir}" || exit
	if [ -f "${executable}" ]; then
		localbuild=$(${executable} -version 2>&1 >/dev/null | awk '{print $5}')
		fn_print_ok "Checking local build: ${remotelocation}"
		fn_script_log_pass "Checking local build"
	else
		localbuild="0"
		fn_print_error "Checking local build: ${remotelocation}"
		fn_script_log_error "Checking local build"
	fi
}

fn_update_mumble_remotebuild(){
	# Gets remote build info.
	remotebuild=$(curl -s "https://api.github.com/repos/mumble-voip/mumble/releases/latest" | grep 'murmur-static_x86.*\.bz2"' | tail -1 | awk -F"/" '{ print $8 }')
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

fn_update_mumble_compare(){
	# Removes dots so if statement can compare version numbers.
	fn_print_dots "Checking for update: ${remotelocation}"
	localbuilddigit=$(echo -e "${localbuild}" | tr -cd '[:digit:]')
	remotebuilddigit=$(echo -e "${remotebuild}" | tr -cd '[:digit:]')
	if [ "${localbuilddigit}" -ne "${remotebuilddigit}" ]||[ "${forceupdate}" == "1" ]; then
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		echo -en "\n"
		echo -e "Update available"
		echo -e "* Local build: ${red}${localbuild} ${mumblearch}${default}"
		echo -e "* Remote build: ${green}${remotebuild} ${mumblearch}${default}"
		echo -en "\n"
		fn_script_log_info "Update available"
		fn_script_log_info "Local build: ${localbuild} ${mumblearch}"
		fn_script_log_info "Remote build: ${remotebuild} ${mumblearch}"
		fn_script_log_info "${localbuild} > ${remotebuild}"

		unset updateonstart
		check_status.sh
		# If server stopped.
		if [ "${status}" == "0" ]; then
			exitbypass=1
			fn_update_mumble_dl
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
			fn_update_mumble_dl
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
		echo -e "* Local build: ${green}${localbuild} ${mumblearch}${default}"
		echo -e "* Remote build: ${green}${remotebuild} ${mumblearch}${default}"
		echo -en "\n"
		fn_script_log_info "No update available"
		fn_script_log_info "Local build: ${localbuild} ${mumblearch}"
		fn_script_log_info "Remote build: ${remotebuild} ${mumblearch}"
	fi
}

# The location where the builds are checked and downloaded.
remotelocation="mumble.info"

# Game server architecture.
mumblearch="x86"

if [ "${firstcommandname}" == "INSTALL" ]; then
	fn_update_mumble_remotebuild
	fn_update_mumble_dl
else
	fn_print_dots "Checking for update: ${remotelocation}"
	fn_script_log_info "Checking for update: ${remotelocation}"
	fn_update_mumble_localbuild
	fn_update_mumble_remotebuild
	fn_update_mumble_compare
fi
