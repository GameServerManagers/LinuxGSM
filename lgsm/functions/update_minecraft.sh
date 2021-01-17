#!/bin/bash
# LinuxGSM update_minecraft.sh module
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Contributors: http://linuxgsm.com/contrib
# Description: Handles updating of Minecraft servers.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_minecraft_dl(){
	# Generate link to version manifest json.
	remotebuildlink=$(curl -s "https://launchermeta.${remotelocation}/mc/game/version_manifest.json" | jq -r --arg branch ${branch} --arg mcversion ${remotebuild} '.versions | .[] | select(.type==$branch and .id==$mcversion) | .url')
	# Generate link to server.jar
	remotebuildurl=$(curl -s "${remotebuildlink}" | jq -r '.downloads.server.url')

	fn_fetch_file "${remotebuildurl}" "" "" "" "${tmpdir}" "minecraft_server.${remotebuild}.jar" "" "norun" "noforce" "nomd5"
	echo -e "copying to ${serverfiles}...\c"
	cp "${tmpdir}/minecraft_server.${remotebuild}.jar" "${serverfiles}/minecraft_server.jar"
	local exitcode=$?
	if [ "${exitcode}" == "0" ]; then
		fn_print_ok_eol_nl
		fn_script_log_pass "Copying to ${serverfiles}"
		chmod u+x "${serverfiles}/minecraft_server.jar"
		fn_clear_tmp
	else
		fn_print_fail_eol_nl
		fn_script_log_fatal "Copying to ${serverfiles}"
		fn_clear_tmp
		core_exit.sh
	fi
}

fn_update_minecraft_localbuild(){
	# Gets local build info.
	fn_print_dots "Checking local build: ${remotelocation}"
	# Uses executable to find local build.
	cd "${executabledir}" || exit
	if [ -f "minecraft_server.jar" ]; then
		localbuild=$(unzip -p "minecraft_server.jar" version.json | jq -r '.id')
		fn_print_ok "Checking local build: ${remotelocation}"
		fn_script_log_pass "Checking local build"
	else
		localbuild="0"
		fn_print_error "Checking local build: ${remotelocation}"
		fn_script_log_error "Checking local build"
	fi
}

fn_update_minecraft_remotebuild(){
	# Gets remote build info.
	# Latest release.
	if [ "${branch}" == "release" ] && [ "${mcversion}" == "latest" ]; then
		remotebuild=$(curl -s "https://launchermeta.${remotelocation}/mc/game/version_manifest.json" | jq -r '.latest.release')
	# Latest snapshot.
	elif [ "${branch}" == "snapshot" ] && [ "${mcversion}" == "latest" ]; then
		remotebuild=$(curl -s "https://launchermeta.${remotelocation}/mc/game/version_manifest.json" | jq -r '.latest.snapshot')
	# Specific release/snapshot.
	else
		remotebuild=$(curl -s "https://launchermeta.${remotelocation}/mc/game/version_manifest.json" | jq -r --arg branch ${branch} --arg mcversion ${mcversion} '.versions | .[] | select(.type==$branch and .id==$mcversion) | .id')
	fi

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

fn_update_minecraft_compare(){
	# Removes dots so if statement can compare version numbers.
	fn_print_dots "Checking for update: ${remotelocation}"
	if [ "${localbuild}" != "${remotebuild}" ]||[ "${forceupdate}" == "1" ]; then
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		echo -en "\n"
		echo -e "Update available"
		echo -e "* Local build: ${red}${localbuild}${default}"
		echo -e "* Remote build: ${green}${remotebuild}${default}"
		if [ -n "${branch}" ]; then
			echo -e "* Branch: ${branch}"
		fi
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
			fn_update_minecraft_dl
			if [ "${requirerestart}" == "1" ]; then
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
			fn_update_minecraft_dl
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
		echo -e "No update available"
		echo -e "* Local build: ${green}${localbuild}${default}"
		echo -e "* Remote build: ${green}${remotebuild}${default}"
		if [ -n "${branch}" ]; then
			echo -e "* Branch: ${branch}"
		fi
		echo -en "\n"
		fn_script_log_info "No update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuild}"
		if [ -n "${branch}" ]; then
			fn_script_log_info "Branch: ${branch}"
		fi
	fi
}

# The location where the builds are checked and downloaded.
remotelocation="mojang.com"

if [ "${firstcommandname}" == "INSTALL" ]; then
	fn_update_minecraft_remotebuild
	fn_update_minecraft_dl
else
	fn_print_dots "Checking for update"
	fn_print_dots "Checking for update: ${remotelocation}"
	fn_script_log_info "Checking for update: ${remotelocation}"
	fn_update_minecraft_localbuild
	fn_update_minecraft_remotebuild
	fn_update_minecraft_compare
fi
