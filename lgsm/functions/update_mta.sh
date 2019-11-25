#!/bin/bash
# LinuxGSM update_mta.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Handles updating of Multi Theft Auto servers.

local commandname="UPDATE"
local commandaction="Update"
local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

fn_update_mta_dl(){
	fn_fetch_file "http://linux.mtasa.com/dl/multitheftauto_linux_x64.tar.gz" "${tmpdir}" "multitheftauto_linux_x64.tar.gz"
	mkdir "${tmpdir}/multitheftauto_linux_x64"
	fn_dl_extract "${tmpdir}" "multitheftauto_linux_x64.tar.gz" "${tmpdir}/multitheftauto_linux_x64"
	echo -e "copying to ${serverfiles}...\c"
	cp -R "${tmpdir}/multitheftauto_linux_x64/multitheftauto_linux_x64/"* "${serverfiles}"
	local exitcode=$?
	if [ "${exitcode}" == "0" ]; then
		fn_print_ok_eol_nl
		fn_script_log_pass "Copying to ${serverfiles}"
		chmod u+x "${serverfiles}/mta-server64"
		fn_clear_tmp
	else
		fn_print_fail_eol_nl
		fn_script_log_fatal "Copying to ${serverfiles}"
		core_exit.sh
	fi
}

fn_update_mta_localbuild(){
	# Gets local build info.
	fn_print_dots "Checking for update: ${remotelocation}: checking local build"
	# Uses log file to gather info.
	# Gives time for log file to generate.
	if [ ! -f "${serverfiles}/mods/deathmatch/logs/server.log" ]; then
		fn_print_error "Checking for update: ${remotelocation}: checking local build"
		fn_print_error_nl "Checking for update: ${remotelocation}: checking local build: no log files"
		fn_script_log_error "No log file found"
		fn_print_info_nl "Checking for update: ${remotelocation}: checking local build: forcing server restart"
		fn_script_log_info "Forcing server restart"
		exitbypass=1
		command_stop.sh
		exitbypass=1
		command_start.sh
		totalseconds=0
		# Check again, allow time to generate logs.
		while [ ! -f "${serverfiles}/mods/deathmatch/logs/server.log" ]; do
			sleep 1
			fn_print_info "Checking for update: ${remotelocation}: checking local build: waiting for log file: ${totalseconds}"
			if [ -v "${loopignore}" ]; then
				loopignore=1
				fn_script_log_info "Waiting for log file to generate"
			fi

			if [ "${totalseconds}" -gt "120" ]; then
				localbuild="0"
				fn_print_error "Checking for update: ${remotelocation}: waiting for log file: missing log file"
				fn_script_log_error "Missing log file"
				fn_script_log_error "Set localbuild to 0"
			fi

			totalseconds=$((totalseconds + 1))
		done
	fi

	if [ -z "${localbuild}" ]; then
		localbuild=$(grep "= Multi Theft Auto: San Andreas v" "${serverfiles}/mods/deathmatch/logs/server.log" | awk '{ print $7 }' | sed -r 's/^.{1}//' | tail -1)
	fi

	if [ -z "${localbuild}" ]; then
		# Gives time for var to generate.
		end=$((SECONDS+120))
		totalseconds=0
		while [ "${SECONDS}" -lt "${end}" ]; do
			fn_print_info "Checking for update: ${remotelocation}: checking local build: waiting for local build: ${totalseconds}"
			if [ -z "${loopignore}" ]; then
				loopignore=1
				fn_script_log_info "Waiting for local build to generate"
			fi
			localbuild=$(grep "= Multi Theft Auto: San Andreas v" "${serverfiles}/mods/deathmatch/logs/server.log" | awk '{ print $7 }' | sed -r 's/^.{1}//' | tail -1)
			if [ "${localbuild}" ]; then
				break
			fi
			sleep 1
			totalseconds=$((totalseconds + 1))
		done
	fi

	if [ -z "${localbuild}" ]; then
		localbuild="0"
		fn_print_error "Checking for update: ${remotelocation}: waiting for local build: missing local build info"
		fn_script_log_error "Missing local build info"
		fn_script_log_error "Set localbuild to 0"
	else
		fn_print_ok "Checking for update: ${remotelocation}: checking local build"
		fn_script_log_pass "Checking local build"
	fi
}

fn_update_mta_remotebuild(){
	# Gets remote build info.
	majorversion=$(curl -s https://raw.githubusercontent.com/multitheftauto/mtasa-blue/master/Server/version.h | grep "#define MTASA_VERSION_MAJOR" | awk '{ print $3 }' | sed 's/\r//g')
	minorversion=$(curl -s https://raw.githubusercontent.com/multitheftauto/mtasa-blue/master/Server/version.h | grep "#define MTASA_VERSION_MINOR" | awk '{ print $3 }' | sed 's/\r//g')
	maintenanceversion=$(curl -s https://raw.githubusercontent.com/multitheftauto/mtasa-blue/master/Server/version.h | grep "#define MTASA_VERSION_MAINTENANCE" | awk '{ print $3 }' | sed 's/\r//g')
	remotebuild="${majorversion}.${minorversion}.${maintenanceversion}"
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

fn_update_mta_compare(){
	# Removes dots so if statement can compare version numbers.
	fn_print_dots "Checking for update: ${remotelocation}"
	localbuilddigit=$(echo -e "${localbuild}" | tr -cd '[:digit:]')
	remotebuilddigit=$(echo -e "${remotebuild}" | tr -cd '[:digit:]')
	if [ "${localbuilddigit}" -ne "${remotebuilddigit}" ]||[ "${forceupdate}" == "1" ]; then
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		if [ "${forceupdate}" == "1" ]; then
			# forceupdate bypasses checks, useful for small build changes
			mtaupdatestatus="forced"
		else
			mtaupdatestatus="available"
		fi
		echo -en "\n"
		echo -e "Update ${mtaupdatestatus}:"
		echo -e "* Local build: ${red}${localbuild}${default}"
		echo -e "* Remote build: ${green}${remotebuild}${default}"
		fn_script_log_info "Update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuild}"
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
			fn_update_mta_dl
			exitbypass=1
			command_start.sh
			exitbypass=1
			command_stop.sh
		# If server started.
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
	fn_update_mta_localbuild
	fn_update_mta_remotebuild
	fn_update_mta_compare
fi
