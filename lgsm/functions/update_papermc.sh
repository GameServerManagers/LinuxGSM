#!/bin/bash
# LinuxGSM update_papermc.sh function
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Handles updating of PaperMC and Waterfall servers.

commandname="UPDATE"
commandaction="Update"
function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_papermc_dl() {
	# get build info
	builddata=$(curl -s "https://${remotelocation}/api/v2/projects/${paperproject}/versions/${paperversion}/builds/${remotebuild}" | jq '.downloads')
	buildname=$(echo -e "${builddata}" | jq -r '.application.name')
	buildsha256=$(echo -e "${builddata}" | jq -r '.application.sha256')

	fn_fetch_file "https://${remotelocation}/api/v2/projects/${paperproject}/versions/${paperversion}/builds/${remotebuild}/downloads/${buildname}" "" "" "" "${tmpdir}" "${buildname}" "nochmodx" "norun" "force" "${buildsha256}"

	echo -e "copying to ${serverfiles}...\c"
	cp -f "${tmpdir}/${buildname}" "${serverfiles}/${executable#./}"
	local exitcode=$?
	if [ "${exitcode}" == "0" ]; then
		fn_print_ok_eol_nl
		fn_script_log_pass "Copying to ${serverfiles}"
		chmod u+x "${serverfiles}/${executable#./}"
		echo "${remotebuild}" > "${localbuildfile}"
		fn_clear_tmp
	else
		fn_print_fail_eol_nl
		fn_script_log_fatal "Copying to ${serverfiles}"
		core_exit.sh
	fi
}

fn_update_papermc_localbuild() {
	# Gets local build info.
	fn_print_dots "Checking local build: ${remotelocation}"
	# Uses version file to get local build.
	localbuild=$(head -n 1 "${localbuildfile}" > /dev/null 2>&1)
	if [ -z "${localbuild}" ]; then
		fn_print_error "Checking local build: ${remotelocation}: missing local build info"
		fn_script_log_error "Missing local build info"
		fn_script_log_error "Set localbuild to 0"
		localbuild="0"
	else
		fn_print_ok "Checking local build: ${remotelocation}"
		fn_script_log_pass "Checking local build"
	fi
}

fn_update_papermc_remotebuild() {
	# Gets remote build info.
	remotebuild=$(curl -s "https://${remotelocation}/api/v2/projects/${paperproject}/versions/${paperversion}" | jq -r '.builds[-1]')
	if [ "${firstcommandname}" != "INSTALL" ]; then
		fn_print_dots "Checking remote build: ${remotelocation}"
		# Checks if remotebuild variable has been set.
		if [ -z "${remotebuild}" ] || [ "${remotebuild}" == "null" ]; then
			fn_print_fail "Checking remote build: ${remotelocation}"
			fn_script_log_fatal "Checking remote build"
			core_exit.sh
		else
			fn_print_ok "Checking remote build: ${remotelocation}"
			fn_script_log_pass "Checking remote build"
		fi
	else
		# Checks if remotebuild variable has been set.
		if [ -z "${remotebuild}" ] || [ "${remotebuild}" == "null" ]; then
			fn_print_failure "Unable to get remote build"
			fn_script_log_fatal "Unable to get remote build"
			core_exit.sh
		fi
	fi
}

fn_update_papermc_compare() {
	fn_print_dots "Checking for update: ${remotelocation}"
	if [ "${localbuild}" != "${remotebuild}" ] || [ "${forceupdate}" == "1" ]; then
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		echo -en "\n"
		echo -e "Update available"
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
			fn_update_ut99_dl
			if [ "${localbuild}" == "0" ]; then
				exitbypass=1
				command_start.sh
				fn_firstcommand_reset
				exitbypass=1
				command_stop.sh
				fn_firstcommand_reset
			fi
		# If server started.
		else
			fn_print_restart_warning
			exitbypass=1
			command_stop.sh
			fn_firstcommand_reset
			exitbypass=1
			fn_update_ut99_dl
			exitbypass=1
			command_start.sh
			fn_firstcommand_reset
		fi
		unset exitbypass
		date +%s > "${lockdir}/lastupdate.lock"
		alert="update"
		alert.sh
	else
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		echo -en "\n"
		echo -e "No update available for version ${paperversion}"
		echo -e "* Local build: ${green}${localbuild}${default}"
		echo -e "* Remote build: ${green}${remotebuild}${default}"
		fn_script_log_info "No update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuild}"
	fi
}

# The location where the builds are checked and downloaded.
remotelocation="papermc.io"

if [ "${shortname}" == "pmc" ]; then
	paperproject="paper"
elif [ "${shortname}" == "vpmc" ]; then
	paperproject="velocity"
elif [ "${shortname}" == "wmc" ]; then
	paperproject="waterfall"
fi

localbuildfile="${serverfiles}/version.txt"

# check version if the user did set one and check it
if [ "${mcversion}" == "latest" ]; then
	paperversion=$(curl -s "https://${remotelocation}/api/v2/projects/${paperproject}" | jq -r '.versions[-1]')
else
	# check if version there for the download from the api
	paperversion=$(curl -s "https://${remotelocation}/api/v2/projects/${paperproject}" | jq -r -e --arg mcversion "${mcversion}" '.versions[]|select(. == $mcversion)')
	if [ -z "${paperversion}" ]; then
		# user passed version does not exist
		fn_print_error_nl "Version ${mcversion} not available from ${remotelocation}"
		fn_script_log_error "Version ${mcversion} not available from ${remotelocation}"
		core_exit.sh
	fi
fi

if [ "${firstcommandname}" == "INSTALL" ]; then
	fn_update_papermc_remotebuild
	fn_update_papermc_dl
else
	fn_print_dots "Checking for update: ${remotelocation}"
	fn_script_log_info "Checking for update: ${remotelocation}"
	sleep 0.5
	fn_update_papermc_localbuild
	fn_update_papermc_remotebuild
	fn_update_papermc_compare
fi
