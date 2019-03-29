#!/bin/bash
# LinuxGSM update_mta.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Handles updating of Multi Theft Auto servers.

local commandname="UPDATE"
local commandaction="Update"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_mta_dl(){
	fn_fetch_file "http://linux.mtasa.com/dl/${numversion}/multitheftauto_linux_x64-${fullversion}.tar.gz" "${tmpdir}" "multitheftauto_linux_x64-${fullversion}.tar.gz"
	mkdir "${tmpdir}/multitheftauto_linux_x64-${fullversion}"
	fn_dl_extract "${tmpdir}" "multitheftauto_linux_x64-${fullversion}.tar.gz" "${tmpdir}/multitheftauto_linux_x64-${fullversion}"
	echo -e "copying to ${serverfiles}...\c"
	cp -R "${tmpdir}/multitheftauto_linux_x64-${fullversion}/multitheftauto_linux_x64-${fullversion}/"* "${serverfiles}"
	local exitcode=$?
	if [ "${exitcode}" == "0" ]; then
		fn_print_ok_eol_nl
		fn_script_log_pass "Copying to ${serverfiles}"
		chmod u+x "${serverfiles}/minecraft_server.jar"
		fn_clear_tmp
	else
		fn_print_fail_eol_nl
		fn_script_log_fatal "Copying to ${serverfiles}"
		core_exit.sh
	fi
}

fn_update_mta_localbuild(){
	# Gets local build info.
	if [ ! -f "${gamelogdir}/server.log" ]; then
		fn_print_error "Checking for update: ${remotelocation}: checking local build"
		sleep 0.5
		fn_print_error_nl "Checking for update: ${remotelocation}: checking local build: no log files"
		fn_script_log_error "Checking for update: ${remotelocation}: checking local build: no log files"
		sleep 0.5
		fn_print_info_nl "Checking for update: ${remotelocation}: checking local build: forcing server restart"
		fn_script_log_info "Forcing server restart"
		sleep 0.5
		exitbypass=1
		command_stop.sh
		exitbypass=1
		command_start.sh
		# Check again and exit on failure.
		if [ ! -f "${gamelogdir}"/server.log ]; then
			localbuild="0"
			fn_print_error "Checking for update: ${remotelocation}: checking local build"
			fn_script_log_error "Checking local build"
		fi
		sleep 0.5
	fi

	if [ -f "${consolelogdir}/${servicename}-console.log" ]; then
		# Get current build from logs
		localbuild=$(grep "= Multi Theft Auto: San Andreas v" "${gamelogdir}/server.log" | awk '{ print $7 }' | sed -r 's/^.{1}//' | tail -1)
		if [ -z "${localbuild}" ]; then
			fn_print_error_nl "Checking for update: ${remotelocation}: checking local build: not found"
			fn_script_log_error "Local build info not found"
			sleep 0.5
			fn_print_info_nl "Checking for update: ${remotelocation}: checking local build: forcing server restart"
			fn_script_log_info "Forcing server restart"
			exitbypass=1
			command_stop.sh
			exitbypass=1
			command_start.sh
			localbuild=$(grep "= Multi Theft Auto: San Andreas v" "${gamelogdir}/server.log" | awk '{ print $7 }' | sed -r 's/^.{1}//' | tail -1)
			if [ -z "${localbuild}" ]; then
				fn_print_fail_nl "Checking for update: ${remotelocation}: checking local build: not found"
				fn_script_log_fatal "Local build version still not found"
				core_exit.sh
			fi
		fi
	fi
}

fn_mta_get_remotebuild(){
	# Gets remote build info.
	fn_print_dots "Checking for update: ${remotelocation}: checking remote build"
	fn_fetch_file "https://raw.githubusercontent.com/multitheftauto/mtasa-blue/master/Server/version.h" "${tmpdir}" "version.h" # we need to find latest stable version here
	local majorversion="$(grep "#define MTASA_VERSION_MAJOR" "${tmpdir}/version.h" | awk '{ print $3 }' | sed 's/\r//g')"
	local minorversion="$(grep "#define MTASA_VERSION_MINOR" "${tmpdir}/version.h" | awk '{ print $3 }' | sed 's/\r//g')"
	local maintenanceversion="$(grep "#define MTASA_VERSION_MAINTENANCE" "${tmpdir}/version.h" | awk '{ print $3 }' | sed 's/\r//g')"
	remotebuild="${majorversion}.${minorversion}.${maintenanceversion}"
	rm -f "${tmpdir}/version.h"
}

fn_update_mta_compare(){
	# Removes dots so if statement can compare version numbers.
	fn_print_dots "Checking for update: ${remotelocation}"
	localbuilddigit=$(echo "${localbuild}" | tr -cd '[:digit:]')
	remotebuilddigit=$(echo "${remotebuild}" | tr -cd '[:digit:]')
	sleep 0.5
	if [ "${localbuilddigit}" -ne "${remotebuilddigit}" ]||[ "${forceupdate}" == "1" ]; then
		fn_print_ok_nl "Checking for update: ${remotelocation}"	
		if [ "${forceupdate}" == "1" ]; then
			# forceupdate bypasses checks, useful for small build changes
			mta_update_string="forced"
		else
			mta_update_string="available"
		fi
		sleep 0.5
		echo -en "\n"
		echo -e "Update ${mta_update_string}:"
		echo -e "* Local build: ${green}${localbuild}${default}"
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
		if [ "${status}" == "0" ]; then
			exitbypass=1
			fn_update_mta_dl
			exitbypass=1
			command_start.sh
			exitbypass=1
			command_stop.sh
		else
			exitbypass=1
			command_stop.sh
			exitbypass=1
			fn_update_mta_dl
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
remotelocation="linux.mtasa.com"
if [ "${installer}" == "1" ]; then
	fn_update_mta_remotebuild
	fn_update_mta_dl
else
	fn_print_dots "Checking for update: ${remotelocation}"
	fn_script_log_info "Checking for update: ${remotelocation}"
	sleep 0.5
	fn_update_mta_localbuild
	fn_update_mta_remotebuild
	fn_update_mta_compare
fi
