#!/bin/bash
# LinuxGSM command_ts3.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Handles updating of teamspeak 3 servers.

local commandname="UPDATE"
local commandaction="Update"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_ts3_dl_legacy(){
	fn_fetch_file "http://dl.4players.de/ts/releases/${ts3_version_number}/teamspeak3-server_linux_${ts3arch}-${ts3_version_number}.tar.bz2" "${tmpdir}" "teamspeak3-server_linux_${ts3arch}-${ts3_version_number}.tar.bz2"
	fn_dl_extract "${tmpdir}" "teamspeak3-server_linux_${ts3arch}-${ts3_version_number}.tar.bz2" "${tmpdir}"
	echo -e "copying to ${serverfiles}...\c"
	fn_script_log "Copying to ${serverfiles}"
	cp -R "${tmpdir}/teamspeak3-server_linux_${ts3arch}/"* "${serverfiles}"
	local exitcode=$?
	if [ "${exitcode}" == "0" ]; then
		fn_print_ok_eol_nl
	else
		fn_print_fail_eol_nl
	fi
}

fn_update_ts3_dl(){
	latestts3releaselink=$(${curlpath} -s 'https://www.teamspeak.com/versions/server.json' | jq -r '.linux.x86_64.mirrors."4Netplayers.de"')
	fn_fetch_file "${latestts3releaselink}" "${tmpdir}" "teamspeak3-server_linux_${ts3arch}-${ts3_version_number}.tar.bz2"
	fn_dl_extract "${tmpdir}" "teamspeak3-server_linux_${ts3arch}-${ts3_version_number}.tar.bz2" "${tmpdir}"
	echo -e "copying to ${serverfiles}...\c"
	fn_script_log "Copying to ${serverfiles}"
	cp -R "${tmpdir}/teamspeak3-server_linux_${ts3arch}/"* "${serverfiles}"
	local exitcode=$?
	if [ "${exitcode}" == "0" ]; then
		fn_print_ok_eol_nl
	else
		fn_print_fail_eol_nl
	fi
}

fn_update_ts3_currentbuild(){
	# Gets current build info
	# Checks if current build info is available. If it fails, then a server restart will be forced to generate logs.
	if [ -z "$(find ./* -name 'ts3server*_0.log')" ]; then
		fn_print_error "Checking for update: teamspeak.com"
		sleep 0.5
		fn_print_error_nl "Checking for update: teamspeak.com: No logs with server version found"
		fn_script_log_error "Checking for update: teamspeak.com: No logs with server version found"
		sleep 0.5
		fn_print_info_nl "Checking for update: teamspeak.com: Forcing server restart"
		fn_script_log_info "Checking for update: teamspeak.com: Forcing server restart"
		sleep 0.5
		exitbypass=1
		command_stop.sh
		exitbypass=1
		command_start.sh
		sleep 0.5
		# Check again and exit on failure.
		if [ -z "$(find ./* -name 'ts3server*_0.log')" ]; then
			fn_print_fail_nl "Checking for update: teamspeak.com: Still No logs with server version found"
			fn_script_log_fatal "Checking for update: teamspeak.com: Still No logs with server version found"
			core_exit.sh
		fi
	fi

	# Get current build from logs
	currentbuild=$(cat $(find ./* -name 'ts3server*_0.log' 2> /dev/null | sort | grep -Ev '${rootdir}/.ts3version' | tail -1) | grep -Eo 'TeamSpeak 3 Server ((\.)?[0-9]{1,3}){1,3}\.[0-9]{1,3}' | grep -Eo '((\.)?[0-9]{1,3}){1,3}\.[0-9]{1,3}' | sort -V | tail -1)
	if [ -z "${currentbuild}" ]; then
		fn_print_error_nl "Checking for update: teamspeak.com: Current build version not found"
		fn_script_log_error "Checking for update: teamspeak.com: Current build version not found"
		sleep 0.5
		fn_print_info_nl "Checking for update: teamspeak.com: Forcing server restart"
		fn_script_log_info "Checking for update: teamspeak.com: Forcing server restart"
		exitbypass=1
		command_stop.sh
		exitbypass=1
		command_start.sh
		currentbuild=$(cat $(find ./* -name 'ts3server*_0.log' 2> /dev/null | sort | grep -Ev '${rootdir}/.ts3version' | tail -1) | grep -Eo 'TeamSpeak 3 Server ((\.)?[0-9]{1,3}){1,3}\.[0-9]{1,3}' | grep -Eo '((\.)?[0-9]{1,3}){1,3}\.[0-9]{1,3}')
		if [ -z "${currentbuild}" ]; then
			fn_print_fail_nl "Checking for update: teamspeak.com: Current build version still not found"
			fn_script_log_fatal "Checking for update: teamspeak.com: Current build version still not found"
			core_exit.sh
		fi
	fi
}

fn_update_ts3_arch(){
# Gets the teamspeak server architecture.
info_distro.sh
if [ "${arch}" == "x86_64" ]; then
	ts3arch="amd64"
elif [ "${arch}" == "i386" ]||[ "${arch}" == "i686" ]; then
	ts3arch="x86"
else
	echo ""
	fn_print_failure "Unknown or unsupported architecture: ${arch}"
	fn_script_log_fatal "Unknown or unsupported architecture: ${arch}"
	core_exit.sh
fi
}


fn_update_ts3_availablebuild(){
	# Gets latest build info.
	if [ "${arch}" == "x86_64" ]; then
		availablebuild="$(${curlpath} -s 'https://www.teamspeak.com/versions/server.json' | jq -r '.linux.x86_64.version')"
	elif [ "${arch}" == "x86" ]; then
		availablebuild="$(${curlpath} -s 'https://www.teamspeak.com/versions/server.json' | jq -r '.linux.x86.version')"
	fi
	ts3_version_number="${availablebuild}"
	# Checks if availablebuild variable has been set
	if [ -z "${availablebuild}" ]||[ "${availablebuild}" == "null" ]; then
		fn_print_fail "Checking for update: teamspeak.com"
		sleep 0.5
		fn_print_fail "Checking for update: teamspeak.com: Not returning version info"
		fn_script_log_fatal "Failure! Checking for update: teamspeak.com: Not returning version info"
		core_exit.sh
	elif [ "${installer}" == "1" ]; then
		:
	else
		fn_print_ok_nl "Checking for update: teamspeak.com"
		fn_script_log_pass "Checking for update: teamspeak.com"
		sleep 0.5
	fi
}

fn_update_ts3_availablebuild_legacy(){
	# Gets latest build info.

	# Grabs all version numbers but not in correct order.
	wget "http://dl.4players.de/ts/releases/?C=M;O=D" -q -O - | grep -i dir | grep -Eo '<a href=\".*\/\">.*\/<\/a>' | grep -Eo '[0-9\.?]+' | uniq > "${tmpdir}/.ts3_version_numbers_unsorted.tmp"

	# Sort version numbers
	cat "${tmpdir}/.ts3_version_numbers_unsorted.tmp" | sort -r --version-sort -o "${tmpdir}/.ts3_version_numbers_sorted.tmp"

	# Finds directory with most recent server version.
	while read -r ts3_version_number; do
		wget --spider -q "http://dl.4players.de/ts/releases/${ts3_version_number}/teamspeak3-server_linux_${ts3arch}-${ts3_version_number}.tar.bz2"
		if [ $? -eq 0 ]; then
			availablebuild="${ts3_version_number}"
			# Break while-loop, if the latest release could be found.
			break
		fi
	done < "${tmpdir}/.ts3_version_numbers_sorted.tmp"

	# Tidy up
	rm -f "${tmpdir}/.ts3_version_numbers_unsorted.tmp"
	rm -f "${tmpdir}/.ts3_version_numbers_sorted.tmp"

	# Checks availablebuild info is available
	if [ -z "${availablebuild}" ]; then
		fn_print_fail "Checking for update: teamspeak.com"
		sleep 0.5
		fn_print_fail "Checking for update: teamspeak.com: Not returning version info"
		fn_script_log_fatal "Failure! Checking for update: teamspeak.com: Not returning version info"
		core_exit.sh
	elif [ "${installer}" == "1" ]; then
		:
	else
		fn_print_ok "Checking for update: teamspeak.com"
		fn_script_log_pass "Checking for update: teamspeak.com"
		sleep 0.5
	fi
}

fn_update_ts3_compare(){
	# Removes dots so if can compare version numbers
	currentbuilddigit=$(echo "${currentbuild}" | tr -cd '[:digit:]')
	availablebuilddigit=$(echo "${availablebuild}" | tr -cd '[:digit:]')

	if [ "${currentbuilddigit}" -lt "${availablebuilddigit}" ]; then
		echo -e "\n"
		echo -e "Update available:"
		sleep 0.5
		echo -e "	Current build: ${red}${currentbuild} ${ts3arch}${default}"
		echo -e "	Available build: ${green}${availablebuild} ${ts3arch}${default}"
		echo -e ""
		sleep 0.5
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
			fn_update_ts3_dl
			exitbypass=1
			command_start.sh
			exitbypass=1
			command_stop.sh
		else
			exitbypass=1
			command_stop.sh
			fn_update_ts3_dl
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

fn_update_ts3_arch
if [ "${installer}" == "1" ]; then
	# if jq available uses json update checker
	if [ "$(command -v jq >/dev/null 2>&1)" ]; then
		fn_update_ts3_availablebuild
		fn_update_ts3_dl
	else
		fn_update_ts3_availablebuild_legacy
		fn_update_ts3_dl_legacy
	fi
else
	# Checks for server update from teamspeak.com using a mirror dl.4players.de.
	fn_print_dots "Checking for update: teamspeak.com"
	fn_script_log_info "Checking for update: teamspeak.com"
	sleep 0.5
	fn_update_ts3_currentbuild
	if [ "$(command -v jq >/dev/null 2>&1)" ]; then
		fn_update_ts3_availablebuild
	else
		fn_update_ts3_availablebuild_legacy
	fi
	fn_update_ts3_compare
fi
