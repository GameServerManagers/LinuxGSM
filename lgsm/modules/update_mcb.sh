#!/bin/bash
# LinuxGSM update_mcb.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Handles updating of Minecraft Bedrock servers.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_dl() {
	fn_fetch_file "${remotebuildurl}" "" "" "" "${tmpdir}" "bedrock_server.${remotebuildversion}.zip" "nochmodx" "norun" "noforce" "nohash"
	echo -e "Extracting to ${serverfiles}...\c"
	if [ "${firstcommandname}" == "INSTALL" ]; then
		unzip -oq "${tmpdir}/bedrock_server.${remotebuildversion}.zip" -x "server.properties" -d "${serverfiles}"
	else
		unzip -oq "${tmpdir}/bedrock_server.${remotebuildversion}.zip" -x "permissions.json" "server.properties" "allowlist.json" -d "${serverfiles}"
	fi
	exitcode=$?
	if [ "${exitcode}" -ne 0 ]; then
		fn_print_fail_eol_nl
		fn_script_log_fail "Extracting ${local_filename}"
		if [ -f "${lgsmlog}" ]; then
			echo -e "${extractcmd}" >> "${lgsmlog}"
		fi
		echo -e "${extractcmd}"
		fn_clear_tmp
		core_exit.sh
	else
		fn_print_ok_eol_nl
		if [ -f "${lgsmlog}" ]; then
			fn_script_log_pass "Extracting ${local_filename}"
		fi
		fn_clear_tmp
	fi
}

fn_update_localbuild() {
	# Gets local build info.
	fn_print_dots "Checking local build: ${remotelocation}"
	# Uses log file to get local build.
	localbuild=$(grep -hoP 'Version:\s*\K[\d.]+' "${consolelogdir}"/* 2> /dev/null | sort -V -r | head -n1)
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
	apiurl="https://net-secondary.web.minecraft-services.net/api/v1.0/download/links"
	remotebuildresponse=$(curl -s "${apiurl}" | jq '.result.links[]')
	# Latest preview.
	if [ "${mcversion}" == "preview" ]; then
		remotebuildurl=$(echo "${remotebuildresponse}" | jq -r 'select(.downloadType == "serverBedrockPreviewLinux") | .downloadUrl')
	# Latest release.
	else
		remotebuildurl=$(echo "${remotebuildresponse}" | jq -r 'select(.downloadType == "serverBedrockLinux") | .downloadUrl')
	fi
	remotebuildversion=$(echo "${remotebuildurl}" | grep -Eo "[.0-9]+[0-9]")
	remotebuildfilename="bedrock-server-${remotebuildversion}.zip"

	if [ "${firstcommandname}" != "INSTALL" ]; then
		fn_print_dots "Checking remote build: ${remotelocation}"
		# Checks if remotebuildversion variable has been set.
		if [ -z "${remotebuildversion}" ] || [ "${remotebuildversion}" == "null" ]; then
			fn_print_fail "Checking remote build: ${remotelocation}"
			fn_script_log_fail "Checking remote build"
			core_exit.sh
		else
			fn_print_ok "Checking remote build: ${remotelocation}"
			fn_script_log_pass "Checking remote build"
		fi
	else
		# Checks if remotebuild variable has been set.
		if [ -z "${remotebuildversion}" ] || [ "${remotebuildversion}" == "null" ]; then
			fn_print_failure "Unable to get remote build"
			fn_script_log_fail "Unable to get remote build"
			core_exit.sh
		fi
	fi
}

fn_update_compare() {
	fn_print_dots "Checking for update: ${remotelocation}"
	# Update has been found or force update.
	if [ "${localbuild}" != "${remotebuildversion}" ] || [ "${forceupdate}" == "1" ]; then
		# Create update lockfile.
		date '+%s' > "${lockdir:?}/update.lock"
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		echo -en "\n"
		echo -e "Update available"
		echo -e "* Local build: ${red}${localbuild}${default}"
		echo -e "* Remote build: ${green}${remotebuildversion}${default}"
		if [ -n "${branch}" ]; then
			echo -e "* Branch: ${branch}"
		fi
		if [ -f "${rootdir}/.dev-debug" ]; then
			echo -e "Remote build info"
			echo -e "* apiurl: ${apiurl}"
			echo -e "* remotebuildfilename: ${remotebuildfilename}"
			echo -e "* remotebuildurl: ${remotebuildurl}"
			echo -e "* remotebuildversion: ${remotebuildversion}"
		fi
		echo -en "\n"
		fn_script_log_info "Update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuildversion}"
		if [ -n "${branch}" ]; then
			fn_script_log_info "Branch: ${branch}"
		fi
		fn_script_log_info "${localbuild} > ${remotebuildversion}"

		if [ "${commandname}" == "UPDATE" ]; then
			date +%s > "${lockdir}/last-updated.lock"
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
			unset exitbypass
			alert="update"
		elif [ "${commandname}" == "CHECK-UPDATE" ]; then
			alert="check-update"
		fi
		alert.sh
	else
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		echo -en "\n"
		echo -e "No update available"
		echo -e "* Local build: ${green}${localbuild}${default}"
		echo -e "* Remote build: ${green}${remotebuildversion}${default}"
		if [ -n "${branch}" ]; then
			echo -e "* Branch: ${branch}"
		fi
		echo -en "\n"
		fn_script_log_info "No update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuildversion}"
		if [ -n "${branch}" ]; then
			fn_script_log_info "Branch: ${branch}"
		fi
		if [ -f "${rootdir}/.dev-debug" ]; then
			echo -e "Remote build info"
			echo -e "* apiurl: ${apiurl}"
			echo -e "* remotebuildfilename: ${remotebuildfilename}"
			echo -e "* remotebuildurl: ${remotebuildurl}"
			echo -e "* remotebuildversion: ${remotebuildversion}"
		fi
	fi
}

# The location where the builds are checked and downloaded.
remotelocation="minecraft.net"

if [ ! "$(command -v jq 2> /dev/null)" ]; then
	fn_print_fail_nl "jq is not installed"
	fn_script_log_fail "jq is not installed"
	core_exit.sh
fi

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
