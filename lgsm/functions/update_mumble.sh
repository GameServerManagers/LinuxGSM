#!/bin/bash
# LGSM update_mumble.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Handles updating of mumble servers.

local commandname="UPDATE"
local commandaction="Update"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_update_mumble_arch(){
# Mumble is x86 only for now
mumblearch="x86"
}

fn_update_mumble_availablebuild(){
# Gets available build info.
fn_print_info_nl "Checking for update from github.com"
fn_script_log "Checking for update from github.com"
availablebuild=$(curl -s https://api.github.com/repos/mumble-voip/mumble/releases/latest | grep 'murmur-static_x86.*\.bz2"' | tail -1 | awk -F"/" '{ print $8 }')
sleep 1
	
# Checks if availablebuild variable has been set
if [ -z "${availablebuild}" ]; then
	fn_print_fail "Checking for update from github.com"
	sleep 1
	fn_print_fail "Checking for update: github.com: Not returning version info"
	fn_script_log_fatal "Failure! Checking for update: github.com Not returning version info"
	core_exit.sh
else
	fn_print_ok_nl "Checking for update from github.com"
	fn_script_log_pass "Checking for update from github.com"
	sleep 1
fi
}

fn_update_mumble_currentbuild(){
# Gets current build info
fn_print_info "Checking current server build"
sleep 1
	# Checks if current build info is available. If it fails, then a server restart will be forced to generate logs.
	if [ ! -f ""${consolelogdir}"/"${servicename}"-console.log" ]; then
		fn_print_info_nl "No current log found, can't retrieve current server build"
		fn_script_log_info "No current log found, can't retrieve current server build"
		sleep 1
		fn_print_info_nl "Forcing server restart"
		fn_script_log_info "Forcing server restart"
		sleep 1
		exitbypass=1
		command_stop.sh
		exitbypass=1
		command_start.sh
		sleep 1
		# Check again and exit on failure.
		if [ ! -f ""${consolelogdir}"/"${servicename}"-console.log" ]; then
			fn_print_fail_nl "Still no logs found, can't retrieve server version
			fn_script_log_fatal "Still no logs found, can't retrieve server version"
			core_exit.sh
		else 
		  fn_print_ok_nl "Logs found"
		  fn_script_log "Logs found"
		  sleep 1
		fi
	fi
	
# Get current build from logs	
currentbuild=$(cat "${consolelogdir}"/"${servicename}"-console.log 2> /dev/null | sort | egrep 'Murmur ((\.)?[0-9]{1,3}){1,3}\.[0-9]{1,3}' | awk '{print $4}')

	if [ -z "${currentbuild}" ]; then
		fn_print_info_nl "Can't find current build version in logs"
		fn_script_log_error "Can't find current build version in logs"
		sleep 1
		fn_print_info_nl "Forcing server restart"
		fn_script_log_info "Forcing server restart"
		exitbypass=1
		command_stop.sh
		exitbypass=1
		command_start.sh
		currentbuild=$(cat "${consolelogdir}"/"${servicename}"-console.log 2> /dev/null | sort | egrep 'Murmur ((\.)?[0-9]{1,3}){1,3}\.[0-9]{1,3}' | awk '{print $4}')
		if [ -z "${currentbuild}" ]; then
			fn_print_fail_nl "Sorry, current build version still not found"
			fn_script_log_fatal "Sorry, current build version still not found"
			core_exit.sh
		fi
	fi
}

fn_update_mumble_compare(){
	# Removes dots so if can compare version numbers
	currentbuilddigit=$(echo "${currentbuild}"|tr -cd '[:digit:]')
	availablebuilddigit=$(echo "${availablebuild}"|tr -cd '[:digit:]')

	if [ "${currentbuilddigit}" -ne "${availablebuilddigit}" ]; then
		echo -e "\n"
		echo -e "Update available:"
		sleep 1
		echo -e "	Current build: ${red}${currentbuild} ${architecture}${default}"
		echo -e "	Available build: ${green}${availablebuild} ${architecture}${default}"
		echo -e ""
		sleep 1
		echo ""
		echo -en "Applying update.\r"
		sleep 1
		echo -en "Applying update..\r"
		sleep 1
		echo -en "Applying update...\r"
		sleep 1
		echo -en "\n"
		fn_script_log "Update available"
		fn_script_log "Current build: ${currentbuild}"
		fn_script_log "Available build: ${availablebuild}"
		fn_script_log "${currentbuild} > ${availablebuild}"

		unset updateonstart

		check_status.sh
		if [ "${status}" == "0" ]; then
			fn_update_mumble_dl
			exitbypass=1
			command_start.sh
			exitbypass=1
			command_stop.sh
		else
			exitbypass=1
			command_stop.sh
			fn_update_mumble_dl
			exitbypass=1
			command_start.sh
		fi
		alert="update"
		alert.sh
	else
		echo -e "\n"
		echo -e "No update available:"
		echo -e "	Current version: ${green}${currentbuild}${default}"
		echo -e "	Available version: ${green}${availablebuild}${default}"
		echo -e ""
		fn_print_ok_nl "No update available"
		fn_script_log_info "Current build: ${currentbuild}"
		fn_script_log_info "Available build: ${availablebuild}"
	fi
}

fn_update_mumble_dl(){
  mumblefilename="murmur-static_${mumblearch}-${mumble_version_number}.tar.bz2"
	fn_fetch_file "https://github.com/mumble-voip/mumble/releases/download/${mumblefilename}" "${lgsmdir}/tmp" "${mumblefilename}"
	fn_dl_extract "${lgsmdir}/tmp" "${mumblefilename}" "${lgsmdir}/tmp"
	echo -e "copying to ${filesdir}...\c"
	fn_script_log "Copying to ${filesdir}"
	cp -R "${lgsmdir}/tmp/murmur-static_${mumblearch}-${mumble_version_number}/"* "${filesdir}"
	local exitcode=$?
	if [ ${exitcode} -eq 0 ]; then
		fn_print_ok_eol_nl
	else
		fn_print_fail_eol_nl
	fi
}

fn_update_mubmle_arch
if [ "${installer}" == "1" ]; then
	fn_update_ts3_availablebuild
	fn_update_ts3_dl
else
	# Checks for server update from teamspeak.com using a mirror dl.4players.de.
	fn_print_dots "Checking for update: teamspeak.com"
	fn_script_log_info "Checking for update: teamspeak.com"
	sleep 1
	fn_update_ts3_currentbuild
	fn_update_ts3_availablebuild
	fn_update_ts3_compare
fi
