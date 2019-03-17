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
	fn_print_dots "Checking for update: factorio.com: checking local build"
	cd "${executabledir}" || exit
	if [ -f "${executable}" ]; then
		localbuild=$(${executable} --version | grep "Version:" | awk '{print $2}')
		fn_print_ok "Checking for update: factorio.com: checking local build"
		fn_script_log_pass "Checking local build"
	else
		localbuild="0"
		fn_print_fail "Checking for update: factorio.com: checking local build"
		fn_script_log_fatal "Checking local build"
	fi	
	sleep 0.5
}

fn_update_factorio_remotebuild(){
	# Gets remote build info.
	fn_print_dots "Checking for update: factorio.com: checking remote build"
	remotebuild=$(${curlpath} -s https://factorio.com/get-download/${downloadbranch}/headless/${factorioarch} | grep -o '[0-9]\.[0-9]\{1,\}\.[0-9]\{1,\}' | head -1)
	
	# Checks if remotebuild variable has been set.
	if [ -v "${remotebuild}" ]; then
		fn_print_fail "Checking for update: factorio.com: checking remote build"
		fn_script_log_fatal "Checking remote build"
		core_exit.sh
	else
		fn_print_ok "Checking for update: factorio.com: checking remote build"
		fn_script_log_pass "Checking remote build"
	fi
	sleep 0.5	
}

fn_update_factorio_compare(){
	# Removes dots so if statement can compare version numbers.
	fn_print_dots "Checking for update: factorio.com"
	localbuilddigit=$(echo "${localbuild}" | tr -cd '[:digit:]')
	remotebuilddigit=$(echo "${remotebuild}" | tr -cd '[:digit:]')
	sleep 0.5
	if [ "${localbuilddigit}" -ne "${remotebuilddigit}" ]; then
		fn_print_ok_nl "Checking for update: factorio.com"
		sleep 0.5
		echo -en "\n"		
		echo -e "Update available"
		echo -e "* Local build: ${green}${localbuild} ${factorioarch} ${branch}${default}"
		echo -e "* Remote build: ${green}${remotebuild} ${factorioarch} ${branch}${default}"
		fn_script_log_info "Update available"
		fn_script_log_info "Local build: ${localbuild} ${factorioarch} ${branch}"
		fn_script_log_info "Remote build: ${remotebuild} ${factorioarch} ${branch}"
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
		echo -e "* Local build: ${green}${localbuild} ${factorioarch} ${branch}${default}"
		echo -e "* Remote build: ${green}${remotebuild} ${factorioarch} ${branch}${default}"
		fn_script_log_info "No update available"
		fn_script_log_info "Local build: ${localbuild} ${factorioarch} ${branch}"
		fn_script_log_info "Remote build: ${remotebuild} ${factorioarch} ${branch}"
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
	fn_update_factorio_remotebuild
	fn_update_factorio_dl
else
	# Checks for server update from factorio.com.
	fn_print_dots "Checking for update: factorio.com"
	fn_script_log_info "Checking for update: factorio.com"
	sleep 0.5
	fn_update_factorio_localbuild
	fn_update_factorio_remotebuild
	fn_update_factorio_compare
fi
