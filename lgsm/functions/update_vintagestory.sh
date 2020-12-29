#!/bin/bash
# LinuxGSM update_vintagestory.sh function
# Author: Christian Birk
# Website: https://linuxgsm.com
# Description: Handles updating of Vintage Story servers.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

remotelocation="vintagestory.at"
apiurl="http://api.${remotelocation}/stable-unstable.json"
local_version_file="${datadir}/vintagestory_version"

fn_update_vs_remotebuild(){
	if [ "${branch}" == "unstable" ]; then
		remotebuild=$(curl -s "${apiurl}" | jq -r '[ to_entries[] ] | .[].key' | grep -E "\-rc|\-pre" | sort -r -V | head -1)
	else
		remotebuild=$(curl -s "${apiurl}" | jq -r '[ to_entries[] ] | .[].key' | grep -Ev "\-rc|\-pre" | sort -r -V | head -1)
	fi
}

fn_update_vs_get_installed_version(){
	localbuild=$(cat "${local_version_file}" )
	# Alternative: get version from executeable $(mono .exe --version)
}

fn_update_vs_dl(){
	# get version info for download
	vsapiresponse=$(curl -s "${apiurl}" | jq --arg version "${remotebuild}" '.[$version].server')
	remotebuildfile=$( echo -e "${vsapiresponse}" | jq -r '.filename' )
	remotebuildlink=$( echo -e "${vsapiresponse}" | jq -r '.urls.cdn' )
	remotebuildmd5=$( echo -e "${vsapiresponse}" | jq -r '.md5' )

	# Download and extract files to serverfiles
	fn_fetch_file "${remotebuildlink}" "" "" "" "${tmpdir}" "${remotebuildfile}" "nochmodx" "norun" "force" "${remotebuildmd5}"
	fn_dl_extract "${tmpdir}" "${remotebuildfile}" "${serverfiles}"
	fn_clear_tmp
	echo "${remotebuild}" > "${local_version_file}"
}

if [ -z "${branch}" ]; then
	branch="stable"
fi

if [ "${commandname}" == "INSTALL" ]; then
	fn_update_vs_remotebuild
	if [ -z "${remotebuild}" ]; then
		# cannot get version
		fn_print_fail_eol_nl
		fn_script_log_fatal "Cannot get version from remote"
		core_exit.sh
	else
		# get version proceed
		fn_update_vs_dl
	fi
elif [ "${commandname}" == "UPDATE" ]||[ "${commandname}" == "CHECK-UPDATE" ]; then
	if [ ! -f "${local_version_file}" ]; then
		# server not installed
		fn_print_fail_eol_nl
		fn_script_log_fatal "Vintage story server not installed"
		core_exit.sh
	else
		fn_update_vs_remotebuild
		if [ -z "${remotebuild}" ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "Cannot get version from remote"
			core_exit.sh
		fi
		fn_update_vs_get_installed_version
		if [ "${remotebuild}" != "${localbuild}" ]; then
			fn_print_ok_nl "Checking for update: ${remotelocation}"
			echo -en "\n"
			echo -e "Update available"
			echo -e "* Local build: ${red}${localbuild} ${default}"
			echo -e "* Remote build: ${green}${remotebuild} ${default}"
			echo -e "* Branch: ${branch}"
			echo -en "\n"
			fn_script_log_info "Update available"
			fn_script_log_info "Local build: ${localbuild}"
			fn_script_log_info "Remote build: ${remotebuild}"

			# update server
			if [ "${commandname}" == "UPDATE" ]; then
				unset updateonstart
				check_status.sh
				# If server stopped.
				if [ "${status}" == "0" ]; then
					fn_update_vs_dl
				# If server started.
				else
					fn_print_restart_warning
					exitbypass=1
					command_stop.sh
					fn_firstcommand_reset
					exitbypass=1
					fn_update_vs_dl
					exitbypass=1
					command_start.sh
					fn_firstcommand_reset
					unset exitbypass
				fi
				date +%s > "${lockdir}/lastupdate.lock"
				alert="update"
			elif [ "${commandname}" == "CHECK-UPDATE" ]; then
				alert="check-update"
			fi
			# trigger alert
			alert.sh
		elif [ "${remotebuild}" == "${localbuild}" ]; then
			fn_print_ok_nl "Checking for update: ${remotelocation}"
			echo -en "\n"
			echo -e "No update available"
			echo -e "* Local build: ${green}${localbuild} ${default}"
			echo -e "* Remote build: ${green}${remotebuild} ${default}"
			echo -e "* Branch: ${branch}"
			echo -en "\n"
			fn_script_log_info "No update available"
			fn_script_log_info "Local build: ${localbuild}"
			fn_script_log_info "Remote build: ${remotebuild}"
			fn_script_log_pass "Latest version ${remotebuild} already installed"
		else
			fn_print_fail_eol_nl
			fn_script_log_fatal "Something went wrong"
			core_exit.sh
		fi
	fi
fi
