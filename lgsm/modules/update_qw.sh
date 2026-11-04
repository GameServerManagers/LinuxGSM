#!/bin/bash
# LinuxGSM update_qw.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Handles updating of QuakeWorld servers.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_fail() {
	fn_print_fail_nl "${1}"
	fn_script_log_fail "${1}"
	exitcode=1
	core_exit.sh
}

fn_update_dl() {
	# Verify and stage the complete bundle before changing serverfiles.
	fn_fetch_file "${remotebuildurl}" "" "" "" "${tmpdir}" "${remotebuildfilename}" "nochmodx" "norun" "forcedl" "${remotebuildhash}"
	local stagedir configfile relativefile
	stagedir=$(mktemp -d "${tmpdir}/qw-update.XXXXXXXX") || fn_update_fail "Unable to create QuakeWorld staging directory"
	fn_dl_extract "${tmpdir}" "${remotebuildfilename}" "${stagedir}"
	if [ ! -x "${stagedir}/mvdsv" ] || [ ! -f "${stagedir}/ktx/qwprogs.so" ] || [ ! -f "${stagedir}/ktx/server.cfg" ]; then
		fn_update_fail "Invalid QuakeWorld bundle layout"
	fi

	# Keep existing configs, map lists and local scripts, including config symlinks.
	# New default configs are still installed. Never remove files from serverfiles.
	while IFS= read -r -d '' configfile; do
		relativefile="${configfile#"${stagedir}/"}"
		case "${relativefile,,}" in
			*.cfg | *.conf | *.ini | *.txt | *.sh) ;;
			*)
				if [ "${serverfiles}/${relativefile}" != "${servercfgfullpath}" ]; then
					continue
				fi
				;;
		esac
		if [ -e "${serverfiles}/${relativefile}" ] || [ -L "${serverfiles}/${relativefile}" ]; then
			rm -f "${configfile}" || fn_update_fail "Unable to preserve QuakeWorld config: ${relativefile}"
		fi
	done < <(find "${stagedir}" \( -type f -o -type l \) -print0)

	cp -a "${stagedir}/." "${serverfiles}/" || fn_update_fail "Unable to copy QuakeWorld update"
	echo "${remotebuild}" > "${serverfiles}/build.txt" || fn_update_fail "Unable to save QuakeWorld build"
	fn_clear_tmp
}

fn_update_localbuild() {
	# Gets local build info.
	fn_print_dots "Checking local build: ${remotelocation}"
	# Legacy installations without build.txt are updated once.
	localbuild=$(head -n 1 "${serverfiles}/build.txt" 2> /dev/null)
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
	# Use the dated release, not the mutable release tagged "latest".
	apiurl="https://api.github.com/repos/GameServerManagers/qwserver-build/releases/latest"
	fn_print_dots "Checking remote build: ${remotelocation}"
	remotebuildresponse=$(curl -fsSL --connect-timeout 10 --max-time 60 "${apiurl}") || fn_update_fail "Unable to get QuakeWorld release"
	remotebuild=$(echo "${remotebuildresponse}" | jq -er '.tag_name | select(test("^build-[0-9]{8}$"))') || fn_update_fail "Invalid QuakeWorld release tag"
	remotebuildfilename="nquake.server.linux.${remotebuild#build-}.full.tar.xz"
	remotebuildurl=$(echo "${remotebuildresponse}" | jq -er --arg name "${remotebuildfilename}" '[.assets[] | select(.name == $name)] | select(length == 1) | .[0].browser_download_url | select(type == "string" and startswith("https://"))') || fn_update_fail "Missing QuakeWorld release archive"
	local checksumurl checksums
	checksumurl=$(echo "${remotebuildresponse}" | jq -er '[.assets[] | select(.name == "SHA256SUMS")] | select(length == 1) | .[0].browser_download_url | select(type == "string" and startswith("https://"))') || fn_update_fail "Missing QuakeWorld checksums"
	checksums=$(curl -fsSL --connect-timeout 10 --max-time 60 "${checksumurl}") || fn_update_fail "Unable to get QuakeWorld checksums"
	remotebuildhash=$(echo "${checksums}" | awk -v filename="${remotebuildfilename}" 'NF == 2 && $2 == filename {print $1}')
	if [[ ! "${remotebuildhash}" =~ ^[a-f0-9]{64}$ ]]; then
		fn_update_fail "Missing or invalid QuakeWorld archive checksum"
	fi
	fn_print_ok "Checking remote build: ${remotelocation}"
	fn_script_log_pass "Checking remote build"
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
