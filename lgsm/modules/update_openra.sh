#!/bin/bash
# LinuxGSM update_openra.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Handles updating of OpenRA servers.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_dl() {
	fn_fetch_file "${remotebuildurl}" "" "" "" "${tmpdir}" "${remotebuildfilename}" "chmodx" "norun" "force" "nohash"
	local extractdir
	extractdir=$(mktemp -d "${tmpdir}/openra.XXXXXX") || exit 1
	if ! (cd "${extractdir}" && "${tmpdir}/${remotebuildfilename}" --appimage-extract > /dev/null) || [ ! -x "${extractdir}/squashfs-root/usr/lib/openra/OpenRA.Server" ] || [ ! -x "${extractdir}/squashfs-root/AppRun" ]; then
		fn_print_fail_nl "Extracting OpenRA server files"
		fn_script_log_fail "Extracting OpenRA server files"
		exitcode=1
		core_exit.sh
	fi
	printf '%s\n' "${remotebuild}" > "${extractdir}/squashfs-root/build.txt" || exit 1
	if [ -d "${serverfiles}/openra" ]; then
		mv "${serverfiles}/openra" "${extractdir}/previous" || exit 1
	fi
	if ! mv "${extractdir}/squashfs-root" "${serverfiles}/openra"; then
		if [ -d "${extractdir}/previous" ]; then
			mv "${extractdir}/previous" "${serverfiles}/openra"
		fi
		exitcode=1
		core_exit.sh
	fi
	fn_clear_tmp
}

fn_update_localbuild() {
	fn_print_dots "Checking local build: ${remotelocation}"
	localbuild="0"
	if [ -x "${serverfiles}/openra/AppRun" ] && [ -x "${serverfiles}/openra/usr/lib/openra/OpenRA.Server" ]; then
		localbuild=$(head -n 1 "${serverfiles}/openra/build.txt" 2> /dev/null)
	fi
	if [ -z "${localbuild}" ]; then
		fn_print_error "Checking local build: ${remotelocation}: missing local build info"
		fn_script_log_error "Missing local build info"
		localbuild="0"
	else
		fn_print_ok "Checking local build: ${remotelocation}"
		fn_script_log_pass "Checking local build"
	fi
}

fn_update_remotebuild() {
	if [ "$(uname -m)" != "x86_64" ]; then
		fn_print_fail_nl "OpenRA requires an x86_64 Linux server"
		fn_script_log_fail "OpenRA requires an x86_64 Linux server"
		exitcode=1
		core_exit.sh
	fi
	apiurl="https://api.github.com/repos/OpenRA/OpenRA/releases/latest"
	if ! remotebuildresponse=$(curl --fail --location --silent --show-error --connect-timeout 10 --max-time 60 "${apiurl}"); then
		fn_print_fail_nl "Checking remote build: ${remotelocation}"
		fn_script_log_fail "Checking remote build: ${apiurl}"
		exitcode=1
		core_exit.sh
	fi
	remotebuildfilename="OpenRA-Red-Alert-x86_64.AppImage"
	remotebuild=$(echo "${remotebuildresponse}" | jq -er '.tag_name | select(test("^release-[0-9]+$"))')
	remotebuildurl=$(echo "${remotebuildresponse}" | jq -er --arg filename "${remotebuildfilename}" '[.assets[] | select(.name == $filename)] | select(length == 1) | .[0].browser_download_url')
	if [ -z "${remotebuild}" ] || [[ "${remotebuildurl}" != https://github.com/OpenRA/OpenRA/releases/download/* ]]; then
		fn_print_fail_nl "Unable to get OpenRA release asset"
		fn_script_log_fail "Unable to get OpenRA release asset"
		exitcode=1
		core_exit.sh
	fi
	fn_print_ok "Checking remote build: ${remotelocation}"
	fn_script_log_pass "Checking remote build: ${remotebuild}"
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
remotelocation="github.com/OpenRA/OpenRA"

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
