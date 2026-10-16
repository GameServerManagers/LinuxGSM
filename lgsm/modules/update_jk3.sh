#!/bin/bash
# LinuxGSM update_jk3.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Handles updating of Jedi Academy OpenJK servers.

# shellcheck disable=SC2034 # Used by the module loader.
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_dl() {
	# Download and extract files to GameData.
	fn_fetch_file "${remotebuildurl}" "" "" "" "${tmpdir}" "${remotebuildfilename}" "nochmodx" "norun" "forcedl" "${remotebuildhash:-nohash}"
	# OpenJK archives already have the executable and base/ at their root.
	fn_dl_extract "${tmpdir}" "${remotebuildfilename}" "${systemdir}"
	if [ ! -x "${executabledir}/openjkded.x86_64" ] || [ ! -f "${systemdir}/base/jampgamex86_64.so" ]; then
		fn_print_fail_nl "OpenJK server files are missing after extraction"
		fn_script_log_fail "OpenJK server files are missing after extraction"
		# shellcheck disable=SC2034 # Used by core_exit.sh.
		exitcode=1
		core_exit.sh
	fi
	if ! echo "${remotebuild}" > "${systemdir}/openjk-build.txt"; then
		fn_print_fail_nl "Unable to save the OpenJK build ID"
		fn_script_log_fail "Unable to save the OpenJK build ID"
		# shellcheck disable=SC2034 # Used by core_exit.sh.
		exitcode=1
		core_exit.sh
	fi
	fn_clear_tmp
}

fn_update_localbuild() {
	# Gets local build info.
	fn_print_dots "Checking local build: ${remotelocation}"
	# Uses build file to get local build.
	localbuild=$(head -n 1 "${systemdir}/openjk-build.txt" 2> /dev/null)
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

fn_update_remotebuild() {
	# Gets remote build info.
	apiurl="https://api.github.com/repos/JACoders/OpenJK/releases/latest"
	remotebuildfilename="OpenJK-linux-x86_64.tar.gz"
	remotebuildresponse=$(curl --connect-timeout 10 --max-time 30 --retry 2 --fail --silent --show-error --location "${apiurl}") || remotebuildresponse=""
	# Select exactly one dedicated Linux x86_64 asset.
	remotebuildasset=$(echo "${remotebuildresponse}" | jq -er --arg filename "${remotebuildfilename}" '[.assets[]? | select(.name == $filename)] | select(length == 1) | .[0] | select((.id | type) == "number" and (.browser_download_url | type) == "string")') || remotebuildasset=""
	remotebuildurl=$(echo "${remotebuildasset}" | jq -r '.browser_download_url')
	# The rolling latest tag is reused; replacing its asset changes the asset ID.
	remotebuild=$(echo "${remotebuildasset}" | jq -r '.id')
	remotebuildhash=$(echo "${remotebuildasset}" | jq -r '.digest // empty' | sed -n 's/^sha256://p')

	if [ "${firstcommandname}" != "INSTALL" ]; then
		fn_print_dots "Checking remote build: ${remotelocation}"
	fi
	# Checks if the remote build and download URL have been set.
	if [ -z "${remotebuild}" ] || [ "${remotebuild}" == "null" ] || [ -z "${remotebuildurl}" ] || [ "${remotebuildurl}" == "null" ]; then
		if [ "${firstcommandname}" != "INSTALL" ]; then
			fn_print_fail "Checking remote build: ${remotelocation}"
			fn_script_log_fail "Checking remote build"
		else
			fn_print_fail_nl "Unable to get remote build"
			fn_script_log_fail "Unable to get remote build"
		fi
		# shellcheck disable=SC2034 # Used by core_exit.sh.
		exitcode=1
		core_exit.sh
	elif [ "${firstcommandname}" != "INSTALL" ]; then
		fn_print_ok "Checking remote build: ${remotelocation}"
		fn_script_log_pass "Checking remote build"
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
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuild}"
		if [ -n "${branch}" ]; then
			fn_script_log_info "Branch: ${branch}"
		fi
		fn_script_log_info "${localbuild} > ${remotebuild}"

		if [ "${commandname}" == "UPDATE" ]; then
			unset updateonstart
			fn_update_apply fn_update_dl
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
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuild}"
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

# The location where the builds are checked and downloaded.
remotelocation="github.com"

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
