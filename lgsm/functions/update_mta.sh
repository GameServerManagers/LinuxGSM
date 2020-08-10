#!/bin/bash
# LinuxGSM update_mta.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Handles updating of Multi Theft Auto servers.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_mta_dl(){
	fn_fetch_file "http://linux.mtasa.com/dl/multitheftauto_linux_x64.tar.gz" "" "" "" "${tmpdir}" "multitheftauto_linux_x64.tar.gz" "" "norun" "noforce" "nomd5"
	mkdir "${tmpdir}/multitheftauto_linux_x64"
	fn_dl_extract "${tmpdir}" "multitheftauto_linux_x64.tar.gz" "${tmpdir}/multitheftauto_linux_x64"
	echo -e "copying to ${serverfiles}...\c"
	cp -R "${tmpdir}/multitheftauto_linux_x64/multitheftauto_linux_x64/"* "${serverfiles}"
	local exitcode=$?
	fn_clear_tmp
	if [ "${exitcode}" == "0" ]; then
		fn_print_ok_eol_nl
		fn_script_log_pass "Copying to ${serverfiles}"
		chmod u+x "${serverfiles}/mta-server64"
	else
		fn_print_fail_eol_nl
		fn_script_log_fatal "Copying to ${serverfiles}"
		core_exit.sh
	fi
}

fn_update_mta_localbuild(){
	# Gets local build info.
	fn_print_dots "Checking local build: ${remotelocation}"
	# Uses log file to gather info.
	# Gives time for log file to generate.
	if [ ! -f "${serverfiles}/mods/deathmatch/logs/server.log" ]; then
		fn_print_error "Checking local build: ${remotelocation}"
		fn_print_error_nl "Checking local build: ${remotelocation}: no log files containing version info"
		fn_print_info_nl "Checking local build: ${remotelocation}: forcing server restart"
		fn_script_log_error "No log files containing version info"
		fn_script_log_info "Forcing server restart"
		exitbypass=1
		command_stop.sh
		exitbypass=1
		command_start.sh
		fn_firstcommand_reset
		totalseconds=0
		# Check again, allow time to generate logs.
		while [ ! -f "${serverfiles}/mods/deathmatch/logs/server.log" ]; do
			sleep 1
			fn_print_info "Checking local build: ${remotelocation}: waiting for log file: ${totalseconds}"
			if [ -v "${loopignore}" ]; then
				loopignore=1
				fn_script_log_info "Waiting for log file to generate"
			fi

			if [ "${totalseconds}" -gt "120" ]; then
				localbuild="0"
				fn_print_error "Checking local build: ${remotelocation}: waiting for log file: missing log file"
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
		totalseconds=0
		for seconds in {1..120}; do
			fn_print_info "Checking local build: ${remotelocation}: waiting for local build: ${totalseconds}"
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
		fn_print_error "Checking local build: ${remotelocation}: waiting for local build: missing local build info"
		fn_script_log_error "Missing local build info"
		fn_script_log_error "Set localbuild to 0"
	else
		fn_print_ok "Checking local build: ${remotelocation}"
		fn_script_log_pass "Checking local build"
	fi
}

fn_update_mta_remotebuild(){
	# Gets remote build info.
	majorversion=$(curl -s https://raw.githubusercontent.com/multitheftauto/mtasa-blue/master/Server/version.h | grep "#define MTASA_VERSION_MAJOR" | awk '{ print $3 }' | sed 's/\r//g')
	minorversion=$(curl -s https://raw.githubusercontent.com/multitheftauto/mtasa-blue/master/Server/version.h | grep "#define MTASA_VERSION_MINOR" | awk '{ print $3 }' | sed 's/\r//g')
	maintenanceversion=$(curl -s https://raw.githubusercontent.com/multitheftauto/mtasa-blue/master/Server/version.h | grep "#define MTASA_VERSION_MAINTENANCE" | awk '{ print $3 }' | sed 's/\r//g')
	remotebuild="${majorversion}.${minorversion}.${maintenanceversion}"
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
		echo -en "\n"
		fn_script_log_info "Update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuild}"
		fn_script_log_info "${localbuild} > ${remotebuild}"

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
			fn_firstcommand_reset
		# If server started.
		else
			fn_print_restart_warning
			exitbypass=1
			command_stop.sh
			fn_firstcommand_reset
			exitbypass=1
			fn_update_mta_dl
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
		echo -e "* Local build: ${green}${localbuild}${default}"
		echo -e "* Remote build: ${green}${remotebuild}${default}"
		echo -en "\n"
		fn_script_log_info "No update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuild}"
	fi
}

# The location where the builds are checked and downloaded.
remotelocation="linux.mtasa.com"

if [ "${firstcommandname}" == "INSTALL" ]; then
	fn_update_mta_remotebuild
	fn_update_mta_dl
else
	fn_print_dots "Checking for update"
	fn_print_dots "Checking for update: ${remotelocation}"
	fn_script_log_info "Checking for update: ${remotelocation}"
	fn_update_mta_localbuild
	fn_update_mta_remotebuild
	fn_update_mta_compare
fi
