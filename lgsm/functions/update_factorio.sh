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
		fn_update_factorio_cleanup_tmpdir
	else
		fn_print_fail_eol_nl
		fn_script_log_fatal "Copying to ${serverfiles}"
		core_exit.sh
	fi
}

fn_update_factorio_currentbuild(){
	# Check executable available.
	if [ -f "${executable}" ]; then
		cd "${executabledir}" || exit
		currentbuild=$(${executable} --version | grep "Version:" | awk '{print $2}')
	else
		fn_print_fail
	fi	

}

fn_update_factorio_availablebuild(){
	# Gets latest build info.
		availablebuild=$(${curlpath} -s https://factorio.com/get-download/${downloadbranch}/headless/${factorioarch} | grep -o '[0-9]\.[0-9]\{1,\}\.[0-9]\{1,\}' | head -1)
	
	# Checks if availablebuild variable has been set.
	if [ -v "${availablebuild}" ]; then
		fn_print_fail "Checking for update: factorio.com"
		sleep 0.5
		fn_print_fail "Checking for update: factorio.com: Not returning version info"
		fn_script_log_fatal "Checking for update: factorio.com: Not returning version info"
		core_exit.sh
	elif [ "${installer}" == "1" ]; then
		:
	else
		fn_print_ok "Checking for update: factorio.com"
		fn_script_log_pass "Checking for update: factorio.com"
		sleep 0.5
	fi
}

fn_update_factorio_compare(){
	# Removes dots so if statement can compare version numbers.
	currentbuilddigit=$(echo "${currentbuild}" | tr -cd '[:digit:]')
	availablebuilddigit=$(echo "${availablebuild}" | tr -cd '[:digit:]')

	if [ "${currentbuilddigit}" -ne "${availablebuilddigit}" ]; then
		echo -e "\n"
		echo -e "Update available:"
		sleep 0.5
		echo -e "	Current build: ${red}${currentbuild} ${factorioarch} ${branch} ${default}"
		echo -e "	Available build: ${green}${availablebuild} ${factorioarch} ${branch}${default}"
		echo -e ""
		sleep 0.5
		echo -en "applying update.\r"
		sleep 1
		echo -en "applying update..\r"
		sleep 1
		echo -en "applying update...\r"
		sleep 1
		echo -en "\n"
		fn_script_log "Update available"
		fn_script_log "Current build: ${currentbuild} ${factorioarch}${branch}"
		fn_script_log "Available build: ${availablebuild} ${factorioarch}${branch}"
		fn_script_log "${currentbuild} > ${availablebuild}"

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
		echo -e "\n"
		echo -e "No update available:"
		echo -e "	Current build: ${green}${currentbuild} ${factorioarch} ${branch}${default}"
		echo -e "	Available build: ${green}${availablebuild} ${factorioarch} ${branch}${default}"
		echo -e ""
		fn_print_ok_nl "No update available"
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
