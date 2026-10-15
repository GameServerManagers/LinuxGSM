#!/bin/bash
# LinuxGSM update_fctr.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Handles updating of Factorio servers.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_dl() {
	# Download and extract files to serverfiles.
	fn_fetch_file "${remotebuildurl}" "" "" "" "${tmpdir}" "${remotebuildfilename}" "nochmodx" "norun" "force" "nohash"
	fn_dl_extract "${tmpdir}" "factorio_headless_${factorioarch}-${remotebuild}.tar.xz" "${serverfiles}" "factorio"
	fn_clear_tmp
}

fn_update_localbuild() {
	# Optional arg1: 'silent' to suppress user-facing output
	local mode="${1:-}"
	if [ "${mode}" != "silent" ]; then
		fn_print_dots "Checking local build: ${remotelocation}"
	fi
	# Uses executable to get local build.
	if [ -d "${executabledir}" ]; then
		cd "${executabledir}" || exit
		localbuild=$(${executable} --version | grep -m 1 "Version:" | awk '{print $2}')
	fi
	if [ -z "${localbuild}" ]; then
		if [ "${mode}" != "silent" ]; then
			fn_print_error "Checking local build: ${remotelocation}: missing local build info"
		fi
		fn_script_log_error "Missing local build info"
		fn_script_log_error "Set localbuild to 0"
		localbuild="0"
	else
		if [ "${mode}" != "silent" ]; then
			fn_print_ok "Checking local build: ${remotelocation}"
		fi
		fn_script_log_pass "Checking local build"
	fi
}

fn_update_remotebuild() {
	# Gets remote build info.
	apiurl="https://factorio.com/get-download/${branch}/headless/${factorioarch}"
	remotebuildresponse=$(curl -s "${apiurl}")
	remotebuild=$(echo "${remotebuildresponse}" | grep -o '[0-9]\.[0-9]\{1,\}\.[0-9]\{1,\}' | head -1)
	remotebuildurl="https://factorio.com/get-download/${branch}/headless/${factorioarch}"
	remotebuildfilename="factorio_headless_${factorioarch}-${remotebuild}.tar.xz"

	if [ "${firstcommandname}" != "INSTALL" ]; then
		fn_print_dots "Checking remote build: ${remotelocation}"
		# Checks if remotebuild variable has been set.
		if [ -z "${remotebuild}" ] || [ "${remotebuild}" == "null" ]; then
			fn_print_fail "Checking remote build: ${remotelocation}"
			fn_script_log_fail "Checking remote build"
			core_exit.sh
		else
			fn_print_ok "Checking remote build: ${remotelocation}"
			fn_script_log_pass "Checking remote build"
		fi
	else
		# Checks if remotebuild variable has been set.
		if [ -z "${remotebuild}" ] || [ "${remotebuild}" == "null" ]; then
			fn_print_failure "Unable to get remote build"
			fn_script_log_fail "Unable to get remote build"
			core_exit.sh
		fi
	fi
}

fn_update_compare() {
	fn_print_dots "Checking for update: ${remotelocation}"
	# Update has been found or force update.
	if [ "${localbuild}" != "${remotebuild}" ] || [ "${forceupdate}" == "1" ]; then
		# Create update lockfile.
		date '+%s' > "${lockdir:?}/update.lock"
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		fn_print "\n"
		fn_print_nl "${bold}${underline}Update${default} available"
		fn_print_nl "* Local build: ${red}${localbuild}${default}"
		fn_print_nl "* Remote build: ${green}${remotebuild}${default}"
		if [ -n "${branch}" ]; then
			fn_print_nl "* Branch: ${branch}"
		fi
		if [ -f "${rootdir}/.dev-debug" ]; then
			fn_print_nl "Remote build info"
			fn_print_nl "* apiurl: ${apiurl}"
			fn_print_nl "* remotebuildfilename: ${remotebuildfilename}"
			fn_print_nl "* remotebuildurl: ${remotebuildurl}"
			fn_print_nl "* remotebuild: ${remotebuild}"
		fi
		fn_print "\n"
		fn_script_log_info "Update available"
		fn_script_log_info "Local build: ${localbuild} ${factorioarch}"
		fn_script_log_info "Remote build: ${remotebuild} ${factorioarch}"
		if [ -n "${branch}" ]; then
			fn_script_log_info "Branch: ${branch}"
		fi
		fn_script_log_info "${localbuild} > ${remotebuild}"

		if [ "${commandname}" == "UPDATE" ]; then
			# Keep track of the build before updating for alert purposes.
			previousbuild="${localbuild}"
			date +%s > "${lockdir:?}/last-updated.lock"
			unset updateonstart
			check_status.sh
			# If server stopped.
			if [ "${status}" == "0" ]; then
				fn_update_dl
				if [ "${localbuild}" == "0" ]; then
					exitbypass=1
					command_start.sh
					fn_firstcommand_reset
					exitbypass=1
					fn_sleep_time_5
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
				fn_update_dl
				exitbypass=1
				command_start.sh
				fn_firstcommand_reset
			fi
			# Refresh local build value after update (silent) so alerts show new version.
			fn_update_localbuild silent
			# Verify the update applied correctly unless forced update to same version.
			if [ "${localbuild}" != "${remotebuild}" ]; then
				# If forced update and version unchanged treat as acceptable; otherwise failure.
				if [ "${forceupdate}" != "1" ] || [ "${previousbuild}" = "${localbuild}" ]; then
					fn_script_log_error "Update verification failed: expected ${remotebuild}, got ${localbuild}"
					fn_print_fail_nl "Update verification failed: expected ${remotebuild}, got ${localbuild}"
					updatefailureexpected="${remotebuild}"
					updatefailuregot="${localbuild}"
					alert="update-failed"
					alert.sh
					core_exit.sh
				fi
			else
				fn_script_log_pass "Update verification success: ${previousbuild} -> ${localbuild}"
			fi
			unset exitbypass
			alert="update"
		elif [ "${commandname}" == "CHECK-UPDATE" ]; then
			alert="check-update"
		fi
		alert.sh
	else
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		fn_print "\n"
		fn_print_nl "${bold}${underline}No update${default} available"
		fn_print_nl "* Local build: ${green}${localbuild}${default}"
		fn_print_nl "* Remote build: ${green}${remotebuild}${default}"
		if [ -n "${branch}" ]; then
			fn_print_nl "* Branch: ${branch}"
		fi
		fn_print "\n"
		fn_script_log_info "No update available"
		fn_script_log_info "Local build: ${localbuild} ${factorioarch}"
		fn_script_log_info "Remote build: ${remotebuild} ${factorioarch}"
		if [ -n "${branch}" ]; then
			fn_script_log_info "Branch: ${branch}"
		fi
		if [ -f "${rootdir}/.dev-debug" ]; then
			fn_print_nl "Remote build info"
			fn_print_nl "* apiurl: ${apiurl}"
			fn_print_nl "* remotebuildfilename: ${remotebuildfilename}"
			fn_print_nl "* remotebuildurl: ${remotebuildurl}"
			fn_print_nl "* remotebuild: ${remotebuild}"
		fi
	fi
}

# Game server architecture.
factorioarch="linux64"

# The location where the builds are checked and downloaded.
remotelocation="factorio.com"

if [ "${firstcommandname}" == "INSTALL" ]; then
	fn_update_remotebuild
	fn_update_dl
else
	fn_print_dots "Checking for update"
	fn_print_dots "Checking for update: ${remotelocation}"
	fn_script_log_info "Checking for update: ${remotelocation}"
	fn_update_localbuild
	fn_update_remotebuild
	fn_update_compare
fi
