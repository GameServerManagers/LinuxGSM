#!/bin/bash
# LinuxGSM update_luanti.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Handles updating of Luanti servers.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_dl() {
	fn_fetch_file "${remotebuildurl}" "" "" "" "${tmpdir}" "${remotebuildfilename}" "nochmodx" "norun" "force" "${remotebuildhash}"
	fn_dl_extract "${tmpdir}" "${remotebuildfilename}" "${serverfiles}" "luanti"
	if [ "${firstcommandname}" == "INSTALL" ] && [ ! -d "${serverfiles}/games/minetest" ]; then
		fn_fetch_file "https://github.com/luanti-org/minetest_game/archive/refs/tags/5.8.0.tar.gz" "" "" "" "${tmpdir}" "minetest_game-5.8.0.tar.gz" "nochmodx" "norun" "force" "33a3bb43b08497a0bdb2f49f140a2829e582d5c16c0ad52be1595c803f706912"
		mkdir -p "${serverfiles}/games/minetest"
		fn_dl_extract "${tmpdir}" "minetest_game-5.8.0.tar.gz" "${serverfiles}/games/minetest" "minetest_game-5.8.0"
	fi
	fn_clear_tmp
}

fn_update_localbuild() {
	local mode="${1:-}"
	if [ "${mode}" != "silent" ]; then
		fn_print_dots "Checking local build: ${remotelocation}"
	fi
	localbuild=$("${executabledir}/${executable#./}" --version 2> /dev/null | awk '/^Luanti / {print $2; exit}')
	localbuild="${localbuild:-0}"
	if [ "${mode}" != "silent" ]; then
		fn_print_ok "Checking local build: ${remotelocation}"
	fi
}

fn_update_remotebuild() {
	case "$(uname -m)" in
		x86_64) luantiarch="x86_64" ;;
		aarch64) luantiarch="aarch64" ;;
		*)
			fn_print_fail_nl "Unsupported Luanti architecture: $(uname -m)"
			fn_script_log_fail "Unsupported Luanti architecture: $(uname -m)"
			core_exit.sh
			;;
	esac
	apiurl="https://api.github.com/repos/rollerozxa/luantiserver/releases/latest"
	remotebuildresponse=$(curl -fsSL --retry 3 "${apiurl}")
	remotebuild=$(echo "${remotebuildresponse}" | jq -r '.tag_name // empty')
	remotebuildfilename="luantiserver-${remotebuild}-${luantiarch}.tar.gz"
	remotebuildurl=$(echo "${remotebuildresponse}" | jq -r --arg name "${remotebuildfilename}" '.assets[]? | select(.name == $name) | .browser_download_url')
	remotebuildhash=$(echo "${remotebuildresponse}" | jq -r --arg name "${remotebuildfilename}" '.assets[]? | select(.name == $name) | .digest // empty' | sed 's/^sha256://')
	if [ -z "${remotebuild}" ] || [ -z "${remotebuildurl}" ] || [[ ! "${remotebuildhash}" =~ ^[0-9a-f]{64}$ ]]; then
		fn_print_fail_nl "Unable to get Luanti release, download URL or SHA256 checksum"
		fn_script_log_fail "Unable to get Luanti release, download URL or SHA256 checksum"
		core_exit.sh
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
			# Keep track of the build before updating for alert purposes.
			previousbuild="${localbuild}"
			unset updateonstart
			fn_update_apply fn_update_dl
			if [ "${updatestatus}" == "0" ] && [ "${localbuild}" == "0" ]; then
				exitbypass=1
				command_start.sh
				fn_firstcommand_reset
				exitbypass=1
				fn_sleep_time_5
				command_stop.sh
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
remotelocation="github.com/rollerozxa/luantiserver"

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
