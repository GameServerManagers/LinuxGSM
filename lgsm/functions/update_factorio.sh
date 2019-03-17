#!/bin/bash
# LinuxGSM update_factorio.sh function
# Author: Daniel Gibbs
# Contributor: Kristian Polso
# Website: https://linuxgsm.com
# Description: Handles updating of Factorio servers.

local commandname="UPDATE"
local commandaction="Update"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_factorio_dl(){
	fn_fetch_file "https://factorio.com/get-download/${downloadbranch}/headless/${factorioarch}" "${tmpdir}" "factorio_headless_${factorioarch}-${availablebuild}.tar.xz"
	fn_dl_extract "${tmpdir}" "factorio_headless_${factorioarch}-${availablebuild}.tar.xz" "${tmpdir}"
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

fn_update_factorio_currentbuild(){
	# Gets current build info.
	fn_print_dots "Checking for update: factorio.com: checking current build"
	cd "${executabledir}" || exit
	if [ -f "${executable}" ]; then
		currentbuild=$(${executable} --version | grep "Version:" | awk '{print $2}')
		fn_print_ok "Checking for update: factorio.com: checking current build"
		fn_script_log_pass "Checking current build"
	else
		currentbuild="0"
		fn_print_fail "Checking for update: factorio.com: checking current build"
		fn_script_log_fail "Checking current build"
	fi	
	sleep 0.5
}

fn_update_factorio_availablebuild(){
	# Gets latest build info.
	fn_print_dots "Checking for update: factorio.com: checking latest build"
	availablebuild=$(${curlpath} -s https://factorio.com/get-download/${downloadbranch}/headless/${factorioarch} | grep -o '[0-9]\.[0-9]\{1,\}\.[0-9]\{1,\}' | head -1)
	
	# Checks if availablebuild variable has been set.
	if [ -v "${availablebuild}" ]; then
		fn_print_fail "Checking for update: factorio.com: checking latest build"
		fn_script_log_fatal "Checking latest build"
		core_exit.sh
	else
		fn_print_ok "Checking for update: factorio.com: checking latest build"
		fn_script_log_pass "Checking latest build"
	fi
	sleep 0.5	
}

fn_update_factorio_compare(){
	# Removes dots so if statement can compare version numbers.
	fn_print_dots "Checking for update: factorio.com"
	currentbuilddigit=$(echo "${currentbuild}" | tr -cd '[:digit:]')
	availablebuilddigit=$(echo "${availablebuild}" | tr -cd '[:digit:]')
	sleep 0.5
	if [ "${currentbuilddigit}" -ne "${availablebuilddigit}" ]; then
		fn_print_ok_nl "Checking for update: factorio.com"
		sleep 0.5
		echo -en "\n"		
		echo -e "Update available"
		echo -e "* Current build: ${green}${currentbuild} ${factorioarch} ${branch}${default}"
		echo -e "* Available build: ${green}${availablebuild} ${factorioarch} ${branch}${default}"
		fn_script_log_info "Update available"
		fn_script_log_info "Current build: ${currentbuild} ${factorioarch} ${branch}"
		fn_script_log_info "Available build: ${availablebuild} ${factorioarch} ${branch}"
		fn_script_log_info "${currentbuild} > ${availablebuild}"		
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
		if [ "${status}" == "0" ]; then
			exitbypass=1
			fn_update_factorio_dl
			exitbypass=1
			command_start.sh
			exitbypass=1
			command_stop.sh
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
		fn_print_ok_nl "Checking for update: factorio.com"
		sleep 0.5
		echo -en "\n"
		echo -e "No update available"
		echo -e "* Current build: ${green}${currentbuild} ${factorioarch} ${branch}${default}"
		echo -e "* Available build: ${green}${availablebuild} ${factorioarch} ${branch}${default}"
		fn_script_log_info "No update available"
		fn_script_log_info "Current build: ${currentbuild} ${factorioarch} ${branch}"
		fn_script_log_info "Available build: ${availablebuild} ${factorioarch} ${branch}"
	fi
}

# Factorio is linux64 only for now.
factorioarch="linux64"

if [ "${branch}" == "stable" ]; then
	downloadbranch="stable"
elif [ "${branch}" == "experimental" ]; then
	downloadbranch="latest"
fi

if [ "${installer}" == "1" ]; then
	fn_update_factorio_availablebuild
	fn_update_factorio_dl
else
	# Checks for server update from factorio.com.
	fn_print_dots "Checking for update: factorio.com"
	fn_script_log_info "Checking for update: factorio.com"
	sleep 0.5
	fn_update_factorio_currentbuild
	fn_update_factorio_availablebuild
	fn_update_factorio_compare
fi
