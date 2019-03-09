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
	fn_script_log "Copying to ${serverfiles}"
	cp -R "${tmpdir}/multitheftauto_linux_x64-${fullversion}/multitheftauto_linux_x64-${fullversion}/"* "${serverfiles}"
	local exitcode=$?
	if [ "${exitcode}" == "0" ]; then
		fn_print_ok_eol_nl
	else
		fn_print_fail_eol_nl
	fi
}

fn_update_mta_currentbuild(){
	# Gets current build info
	# Checks if current build info is available. If it fails, then a server restart will be forced to generate logs.
	if [ ! -f "${gamelogdir}"/server.log ]; then
		fn_print_error "Checking for update: linux.mtasa.com"
		sleep 0.5
		fn_print_error_nl "Checking for update: linux.mtasa.com: No logs with server version found"
		fn_script_log_error "Checking for update: linux.mtasa.com: No logs with server version found"
		sleep 0.5
		fn_print_info_nl "Checking for update: linux.mtasa.com: Forcing server restart"
		fn_script_log_info "Checking for update: linux.mtasa.com: Forcing server restart"
		sleep 0.5
		exitbypass=1
		command_stop.sh
		exitbypass=1
		command_start.sh
		sleep 0.5
		# Check again and exit on failure.
		if [ ! -f "${gamelogdir}"/server.log ]; then
			fn_print_fail_nl "Checking for update: linux.mtasa.com: Still No logs with server version found"
			fn_script_log_fatal "Checking for update: linux.mtasa.com: Still No logs with server version found"
			core_exit.sh
		fi
	fi

	# Get current build from logs
	currentbuild=$(grep "= Multi Theft Auto: San Andreas v" "${gamelogdir}/server.log" | awk '{ print $7 }' | sed -r 's/^.{1}//' | tail -1)
	if [ -z "${currentbuild}" ]; then
		fn_print_error_nl "Checking for update: linux.mtasa.com: Current build version not found"
		fn_script_log_error "Checking for update: linux.mtasa.com: Current build version not found"
		sleep 0.5
		fn_print_info_nl "Checking for update: linux.mtasa.com: Forcing server restart"
		fn_script_log_info "Checking for update: linux.mtasa.com: Forcing server restart"
		exitbypass=1
		command_stop.sh
		exitbypass=1
		command_start.sh
		currentbuild=$(grep "= Multi Theft Auto: San Andreas v" "${gamelogdir}/server.log" | awk '{ print $7 }' | sed -r 's/^.{1}//' | tail -1)
		if [ -z "${currentbuild}" ]; then
			fn_print_fail_nl "Checking for update: linux.mtasa.com: Current build version still not found"
			fn_script_log_fatal "Checking for update: linux.mtasa.com: Current build version still not found"
			core_exit.sh
		fi
	fi
}

fn_mta_get_availablebuild(){
	fn_fetch_file "https://raw.githubusercontent.com/multitheftauto/mtasa-blue/master/Server/version.h" "${tmpdir}" "version.h" # we need to find latest stable version here
	local majorversion="$(grep "#define MTASA_VERSION_MAJOR" "${tmpdir}/version.h" | awk '{ print $3 }' | sed 's/\r//g')"
	local minorversion="$(grep "#define MTASA_VERSION_MINOR" "${tmpdir}/version.h" | awk '{ print $3 }' | sed 's/\r//g')"
	local maintenanceversion="$(grep "#define MTASA_VERSION_MAINTENANCE" "${tmpdir}/version.h" | awk '{ print $3 }' | sed 's/\r//g')"
	numversion="${majorversion}${minorversion}${maintenanceversion}"
	fullversion="${majorversion}.${minorversion}.${maintenanceversion}"
	rm -f "${tmpdir}/version.h"
}

fn_update_mta_compare(){
	# Removes dots so if can compare version numbers
	currentbuilddigit=$(echo "${currentbuild}" | tr -cd '[:digit:]')
	if [ "${currentbuilddigit}" -ne "${numversion}" ]||[ "${forceupdate}" == "1" ]; then
		if [ "${forceupdate}" == "1" ]; then
			# forceupdate bypasses checks, useful for small build changes
			mta_update_string="forced"
		else
			mta_update_string="available"
		fi
		echo -e "\n"
		echo -e "Update ${mta_update_string}:"
		sleep 0.5
		echo -e "	Current build: ${red}${currentbuild} ${default}"
		echo -e "	Available build: ${green}${fullversion} ${default}"
		echo -e ""
		sleep 0.5
		echo -en "applying update.\r"
		sleep 1
		echo -en "applying update..\r"
		sleep 1
		echo -en "applying update...\r"
		sleep 1
		echo -en "\n"
		fn_script_log "Update ${mta_update_string}"
		fn_script_log "Current build: ${currentbuild}"
		fn_script_log "Available build: ${fullversion}"
		fn_script_log "${currentbuild} > ${fullversion}"

		unset updateonstart

		check_status.sh
		if [ "${status}" == "0" ]; then
			fn_update_mta_dl
			exitbypass=1
			command_start.sh
			exitbypass=1
			command_stop.sh
		else
			exitbypass=1
			command_stop.sh
			fn_update_mta_dl
			exitbypass=1
			command_start.sh
		fi
		alert="update"
		alert.sh
	else
		echo -e "\n"
		echo -e "No update available:"
		echo -e "       Current version: ${green}${currentbuild}${default}"
		echo -e "       Available version: ${green}${fullversion}${default}"
		echo -e ""
		fn_print_ok_nl "No update available"
		fn_script_log_info "Current build: ${currentbuild}"
		fn_script_log_info "Available build: ${fullversion}"
	fi
}


if [ "${installer}" == "1" ]; then
	fn_mta_get_availablebuild
	fn_update_mta_dl
else
	# Checks for server update from linux.mtasa.com using the github repo.
	fn_print_dots "Checking for update: linux.mtasa.com"
	fn_script_log_info "Checking for update: linux.mtasa.com"
	sleep 0.5
	fn_update_mta_currentbuild
	fn_mta_get_availablebuild
	fn_update_mta_compare
fi
