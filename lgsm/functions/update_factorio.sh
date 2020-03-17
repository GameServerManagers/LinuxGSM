#!/bin/bash
# LinuxGSM update_factorio.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Handles updating of Factorio servers.

local modulename="UPDATE"
local commandaction="Update"
local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

fn_update_factorio_dl(){
	fn_fetch_file "https://factorio.com/get-download/${downloadbranch}/headless/${factorioarch}" "${tmpdir}" "factorio_headless_${factorioarch}-${remotebuild}.tar.xz"
	fn_dl_extract "${tmpdir}" "factorio_headless_${factorioarch}-${remotebuild}.tar.xz" "${tmpdir}"
	echo -e "copying to ${serverfiles}...\c"
	cp -R "${tmpdir}/factorio/"* "${serverfiles}"
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

fn_update_factorio_localbuild(){
	# Gets local build info.
	fn_print_dots "Checking for update: ${remotelocation}: checking local build"
	# Uses executable to find local build.
	cd "${executabledir}" || exit
	if [ -f "${executable}" ]; then
		localbuild=$(${executable} --version | grep "Version:" | awk '{print $2}')
		fn_print_ok "Checking for update: ${remotelocation}: checking local build"
		fn_script_log_pass "Checking local build"
	else
		localbuild="0"
		fn_print_error "Checking for update: ${remotelocation}: checking local build"
		fn_script_log_error "Checking local build"
	fi
}

fn_update_factorio_remotebuild(){
	# Gets remote build info.
	remotebuild=$(curl -s "https://factorio.com/get-download/${downloadbranch}/headless/${factorioarch}" | grep -o '[0-9]\.[0-9]\{1,\}\.[0-9]\{1,\}' | head -1)
	if [ "${installer}" != "1" ]; then
		fn_print_dots "Checking for update: ${remotelocation}: checking remote build"
		# Checks if remotebuild variable has been set.
		if [ -z "${remotebuild}" ]||[ "${remotebuild}" == "null" ]; then
			fn_print_fail "Checking for update: ${remotelocation}: checking remote build"
			fn_script_log_fatal "Checking remote build"
			core_exit.sh
		else
			fn_print_ok "Checking for update: ${remotelocation}: checking remote build"
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

fn_update_factorio_compare(){
	fn_print_dots "Checking for update: ${remotelocation}"
	# Removes dots so if statement can compare version numbers.
	localbuilddigit=$(echo -e "${localbuild}" | tr -cd '[:digit:]')
	remotebuilddigit=$(echo -e "${remotebuild}" | tr -cd '[:digit:]')
	if [ "${localbuilddigit}" -ne "${remotebuilddigit}" ]||[ "${forceupdate}" == "1" ]; then
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		echo -en "\n"
		echo -e "Update available"
		echo -e "* Local build: ${red}${localbuild} ${factorioarch}${default}"
		echo -e "* Remote build: ${green}${remotebuild} ${factorioarch}${default}"
		if [ -v "${branch}" ]; then
			echo -e "* Branch: ${branch}"
		fi
		fn_script_log_info "Update available"
		fn_script_log_info "Local build: ${localbuild} ${factorioarch}"
		fn_script_log_info "Remote build: ${remotebuild} ${factorioarch}"
		if [ -v "${branch}" ]; then
			fn_script_log_info "Branch: ${branch}"
		fi
		fn_script_log_info "${localbuild} > ${remotebuild}"
		fn_sleep_time
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
		echo -en "\n"
		echo -e "No update available"
		echo -e "* Local build: ${green}${localbuild} ${factorioarch}${default}"
		echo -e "* Remote build: ${green}${remotebuild} ${factorioarch}${default}"
		if [ -v "${branch}" ]; then
			echo -e "* Branch: ${branch}"
		fi
		fn_script_log_info "No update available"
		fn_script_log_info "Local build: ${localbuild} ${factorioarch}"
		fn_script_log_info "Remote build: ${remotebuild} ${factorioarch}"
		if [ -v "${branch}" ]; then
			fn_script_log_info "Branch: ${branch}"
		fi
	fi
}

# The location where the builds are checked and downloaded.
remotelocation="factorio.com"

# Game server architecture.
factorioarch="linux64"

if [ "${branch}" == "stable" ]; then
	downloadbranch="stable"
elif [ "${branch}" == "experimental" ]; then
	downloadbranch="latest"
else
	downloadbranch="${branch}"
fi

if [ "${installer}" == "1" ]; then
	fn_update_factorio_remotebuild
	fn_update_factorio_dl
else
	fn_print_dots "Checking for update: ${remotelocation}"
	fn_script_log_info "Checking for update: ${remotelocation}"
	fn_update_factorio_localbuild
	fn_update_factorio_remotebuild
	fn_update_factorio_compare
fi
