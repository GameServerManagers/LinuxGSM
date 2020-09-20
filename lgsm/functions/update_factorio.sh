#!/bin/bash
# LinuxGSM update_factorio.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Handles updating of Factorio servers.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_factorio_dl(){
	fn_fetch_file "https://factorio.com/get-download/${downloadbranch}/headless/${factorioarch}" "" "" "" "${tmpdir}" "factorio_headless_${factorioarch}-${remotebuild}.tar.xz" "" "norun" "noforce" "nomd5"
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
		fn_clear_tmp
	fi
}

fn_update_factorio_localbuild(){
	# Gets local build info.
	fn_print_dots "Checking local build: ${remotelocation}"
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

fn_update_factorio_compare(){
	fn_print_dots "Checking for update: ${remotelocation}"
	# Removes dots so if statement can compare version numbers.
	fn_print_dots "Checking for update: ${remotelocation}"
	localbuilddigit=$(echo -e "${localbuild}" | tr -cd '[:digit:]')
	remotebuilddigit=$(echo -e "${remotebuild}" | tr -cd '[:digit:]')
	if [ "${localbuilddigit}" -ne "${remotebuilddigit}" ]||[ "${forceupdate}" == "1" ]; then
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		echo -en "\n"
		echo -e "Update available"
		echo -e "* Local build: ${red}${localbuild} ${factorioarch}${default}"
		echo -e "* Remote build: ${green}${remotebuild} ${factorioarch}${default}"
		if [ -n "${branch}" ]; then
			echo -e "* Branch: ${branch}"
		fi
		echo -en "\n"
		fn_script_log_info "Update available"
		fn_script_log_info "Local build: ${localbuild} ${factorioarch}"
		fn_script_log_info "Remote build: ${remotebuild} ${factorioarch}"
		if [ -v "${branch}" ]; then
			fn_script_log_info "Branch: ${branch}"
		fi
		fn_script_log_info "${localbuild} > ${remotebuild}"

		unset updateonstart
		check_status.sh
		# If server stopped.
		if [ "${status}" == "0" ]; then
			exitbypass=1
			fn_update_factorio_dl
			exitbypass=1
			command_start.sh
			fn_firstcommand_reset
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
			fn_update_factorio_dl
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
		echo -e "* Local build: ${green}${localbuild} ${factorioarch}${default}"
		echo -e "* Remote build: ${green}${remotebuild} ${factorioarch}${default}"
		if [ -v "${branch}" ]; then
			echo -e "* Branch: ${branch}"
		fi
		echo -en "\n"
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

if [ "${firstcommandname}" == "INSTALL" ]; then
	fn_update_factorio_remotebuild
	fn_update_factorio_dl
else
	fn_print_dots "Checking for update"
	fn_print_dots "Checking for update: ${remotelocation}"
	fn_script_log_info "Checking for update: ${remotelocation}"
	fn_update_factorio_localbuild
	fn_update_factorio_remotebuild
	fn_update_factorio_compare
fi
