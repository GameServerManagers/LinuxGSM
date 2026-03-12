#!/bin/bash
# LinuxGSM update_cfmc.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Handles updating of CurseForge Minecraft server packs.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_cfmc_parse_fileid_from_url() {
	local input_url="${1}"
	echo "${input_url}" | sed -n 's#.*[\/?&]files/\([0-9]\+\).*#\1#p' | head -n 1
}

fn_cfmc_validate_config() {
	cfmcsource="${cfmcsource:-api}"
	local parsed_fileid
	local missing_settings=()

	if [ "${cfmcsource}" != "api" ] && [ "${cfmcsource}" != "url" ]; then
		fn_print_failure "Invalid cfmcsource: ${cfmcsource}"
		fn_script_log_fail "Invalid cfmcsource: ${cfmcsource}"
		echo -e "Supported values: api | url"
		echo -e "Set in: ${configdirserver}/${selfname}.cfg"
		core_exit.sh
	fi

	if [ -n "${curseforgeurl}" ]; then
		parsed_fileid="$(fn_cfmc_parse_fileid_from_url "${curseforgeurl}")"
		if [ -n "${parsed_fileid}" ] && [ -z "${curseforgefileid}" ]; then
			curseforgefileid="${parsed_fileid}"
		fi
	fi

	if [ "${cfmcsource}" == "api" ]; then
		[ -n "${curseforgemodid}" ] || missing_settings+=("curseforgemodid")
		[ -n "${curseforgefileid}" ] || missing_settings+=("curseforgefileid")
		[ -n "${curseforgeapikey}" ] || missing_settings+=("curseforgeapikey")
	elif [ "${cfmcsource}" == "url" ]; then
		[ -n "${curseforgeurl}" ] || missing_settings+=("curseforgeurl")
	fi

	if [ "${#missing_settings[@]}" -gt 0 ]; then
		fn_print_failure "Missing required CurseForge settings"
		fn_script_log_fail "Missing required CurseForge settings"
		echo -e "Set the following value(s):"
		for setting in "${missing_settings[@]}"; do
			echo -e "* ${setting}"
		done
		echo -e ""
		echo -e "Set non-secret values in: ${configdirserver}/${selfname}.cfg"
		echo -e "Set curseforgeapikey in: ${configdirserver}/secrets-common.cfg or ${configdirserver}/secrets-${selfname}.cfg"
		core_exit.sh
	fi
}

fn_cfmc_api_get_file_data() {
	local fileid="${1}"
	local apiurl="https://api.curseforge.com/v1/mods/${curseforgemodid}/files/${fileid}"
	local apiresponse
	local apiid

	apiresponse=$(curl -sSL -H "x-api-key: ${curseforgeapikey}" "${apiurl}")
	exitcode=$?
	if [ "${exitcode}" -ne 0 ] || [ -z "${apiresponse}" ]; then
		fn_print_failure "Unable to query CurseForge API for file ID ${fileid}"
		fn_script_log_fail "Unable to query CurseForge API for file ID ${fileid}"
		core_exit.sh
	fi

	apiid=$(echo "${apiresponse}" | jq -r '.data.id // empty')
	if [ -z "${apiid}" ]; then
		fn_print_failure "Unable to resolve CurseForge file ID ${fileid}"
		fn_script_log_fail "Unable to resolve CurseForge file ID ${fileid}"
		core_exit.sh
	fi

	echo "${apiresponse}"
}

fn_cfmc_resolve_api_source() {
	local source_fileid="${1:-${curseforgefileid}}"
	local apiresponse
	local server_pack_fileid

	apiresponse="$(fn_cfmc_api_get_file_data "${source_fileid}")"
	server_pack_fileid=$(echo "${apiresponse}" | jq -r '.data.serverPackFileId // 0')
	resolvedfileid="${source_fileid}"

	if [[ "${server_pack_fileid}" =~ ^[0-9]+$ ]] && [ "${server_pack_fileid}" -gt 0 ]; then
		resolvedfileid="${server_pack_fileid}"
		apiresponse="$(fn_cfmc_api_get_file_data "${resolvedfileid}")"
	fi

	remotebuildurl=$(echo "${apiresponse}" | jq -r '.data.downloadUrl // empty')
	remotebuildfilename=$(echo "${apiresponse}" | jq -r '.data.fileName // empty')

	if [ -z "${remotebuildfilename}" ] || [ "${remotebuildfilename}" == "null" ]; then
		remotebuildfilename="curseforge-${resolvedfileid}.zip"
	fi

	if [ -z "${remotebuildurl}" ] || [ "${remotebuildurl}" == "null" ]; then
		fn_print_failure "CurseForge API did not return a downloadable server pack URL for file ${resolvedfileid}"
		fn_script_log_fail "CurseForge API did not return a downloadable server pack URL for file ${resolvedfileid}"
		core_exit.sh
	fi

	remotelocation="curseforge.com"
	localpackpath=""
}

fn_cfmc_resolve_url_source() {
	local parsed_fileid
	parsed_fileid="$(fn_cfmc_parse_fileid_from_url "${curseforgeurl}")"

	if echo "${curseforgeurl}" | grep -Eq '^https?://(www\.)?curseforge\.com/'; then
		if [ -z "${parsed_fileid}" ]; then
			fn_print_failure "Unsupported CurseForge URL: ${curseforgeurl}"
			fn_script_log_fail "Unsupported CurseForge URL: ${curseforgeurl}"
			echo -e "Use a direct archive URL, local archive path, or a CurseForge URL containing /files/<id>."
			core_exit.sh
		fi
		if [ -z "${curseforgemodid}" ] || [ -z "${curseforgeapikey}" ]; then
			fn_print_failure "CurseForge page URL requires curseforgemodid and curseforgeapikey"
			fn_script_log_fail "CurseForge page URL requires curseforgemodid and curseforgeapikey"
			echo -e "Set non-secret values in: ${configdirserver}/${selfname}.cfg"
			echo -e "Set curseforgeapikey in: ${configdirserver}/secrets-common.cfg or ${configdirserver}/secrets-${selfname}.cfg"
			core_exit.sh
		fi
		curseforgefileid="${parsed_fileid}"
		fn_cfmc_resolve_api_source "${parsed_fileid}"
		return
	fi

	if echo "${curseforgeurl}" | grep -Eq '^https?://'; then
		local url_no_query="${curseforgeurl%%\?*}"
		remotebuildfilename="$(basename "${url_no_query}")"
		if [ -z "${remotebuildfilename}" ] || [ "${remotebuildfilename}" == "/" ] || [ "${remotebuildfilename}" == "." ]; then
			remotebuildfilename="curseforge-server-pack.zip"
		fi
		remotebuildurl="${curseforgeurl}"
		remotelocation="$(echo "${curseforgeurl}" | awk -F/ '{print $3}')"
		resolvedsource="${curseforgeurl}"
		localpackpath=""
	elif [ -f "${curseforgeurl}" ]; then
		localpackpath="${curseforgeurl}"
		remotebuildfilename="$(basename "${localpackpath}")"
		remotebuildurl=""
		remotelocation="local file"
		resolvedsource="${localpackpath}"
	else
		fn_print_failure "Invalid curseforgeurl value: ${curseforgeurl}"
		fn_script_log_fail "Invalid curseforgeurl value: ${curseforgeurl}"
		echo -e "Set curseforgeurl to a direct archive URL, a local archive path, or a CurseForge file page URL."
		core_exit.sh
	fi
}

fn_cfmc_build_remote_marker() {
	local marker_source
	local sourcehash

	if [ "${cfmcsource}" == "api" ]; then
		remotebuildversion="cfapi:${curseforgemodid}:${resolvedfileid}"
	else
		marker_source="${curseforgeurl}"
		if [ -z "${marker_source}" ]; then
			marker_source="${resolvedsource}"
		fi
		sourcehash=$(echo -n "${marker_source}" | sha1sum | awk '{print $1}')
		remotebuildversion="cfurl:${sourcehash}"
	fi
}

fn_cfmc_collect_preserve_paths() {
	local levelname
	local preserve_entries
	local preserve_path
	local preserve_raw_paths=()

	cfmc_preserve_paths=()
	levelname=$(sed -n -e 's/^level-name=//p' "${serverfiles}/server.properties" 2> /dev/null | tail -n 1)
	if [ -z "${levelname}" ]; then
		levelname="world"
	fi

	preserve_entries="local;journeymap;kubejs;serverconfig;server.properties;eula.txt;ops.json;whitelist.json;banned-ips.json;banned-players.json;usercache.json;${levelname};${levelname}_nether;${levelname}_the_end;${cfmcpreservepaths}"
	IFS=';' read -r -a preserve_raw_paths <<< "${preserve_entries}"
	for preserve_path in "${preserve_raw_paths[@]}"; do
		preserve_path="$(echo "${preserve_path}" | xargs)"
		preserve_path="${preserve_path#./}"
		preserve_path="${preserve_path#/}"
		preserve_path="${preserve_path%/}"
		if [ -z "${preserve_path}" ]; then
			continue
		fi
		if echo "${preserve_path}" | grep -Eq '(^|/)\.\.(/|$)'; then
			fn_script_log_warn "Skipping unsafe preserve path: ${preserve_path}"
			continue
		fi
		if [[ " ${cfmc_preserve_paths[*]} " != *" ${preserve_path} "* ]]; then
			cfmc_preserve_paths+=("${preserve_path}")
		fi
	done
}

fn_cfmc_backup_preserve() {
	local relpath
	local srcpath

	fn_cfmc_collect_preserve_paths
	cfmc_preserve_dir="${tmpdir}/cfmc-preserve"
	rm -rf "${cfmc_preserve_dir}"
	mkdir -p "${cfmc_preserve_dir}"

	for relpath in "${cfmc_preserve_paths[@]}"; do
		srcpath="${serverfiles}/${relpath}"
		if [ -e "${srcpath}" ]; then
			mkdir -p "${cfmc_preserve_dir}/$(dirname "${relpath}")"
			cp -a "${srcpath}" "${cfmc_preserve_dir}/${relpath}"
		fi
	done
}

fn_cfmc_restore_preserve() {
	local relpath
	local targetpath
	local backup_path

	for relpath in "${cfmc_preserve_paths[@]}"; do
		targetpath="${serverfiles}/${relpath}"
		backup_path="${cfmc_preserve_dir}/${relpath}"
		if [ -e "${backup_path}" ]; then
			rm -rf "${targetpath}"
			mkdir -p "$(dirname "${targetpath}")"
			cp -a "${backup_path}" "${targetpath}"
		fi
	done
}

fn_cfmc_upsert_setting() {
	local setting_name="${1}"
	local setting_value="${2}"
	local config_file="${configdirserver}/${selfname}.cfg"
	local escaped_value

	touch "${config_file}"
	escaped_value=$(echo -n "${setting_value}" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/[&|]/\\&/g')
	if grep -qE "^[[:blank:]]*${setting_name}=" "${config_file}"; then
		sed -i "s|^[[:blank:]]*${setting_name}=.*|${setting_name}=\"${escaped_value}\"|g" "${config_file}"
	else
		echo "${setting_name}=\"${escaped_value}\"" >> "${config_file}"
	fi
}

fn_cfmc_persist_start_command() {
	if [ "${cfmcstartmode}" != "auto" ] || [ -z "${detected_executable}" ]; then
		return
	fi

	fn_cfmc_upsert_setting "preexecutable" "${detected_preexecutable}"
	fn_cfmc_upsert_setting "executable" "${detected_executable}"
	fn_cfmc_upsert_setting "startparameters" "${detected_startparameters}"

	preexecutable="${detected_preexecutable}"
	executable="${detected_executable}"
	startparameters="${detected_startparameters}"
}

fn_cfmc_detect_start_command() {
	local script_name
	local jar_name

	detected_preexecutable=""
	detected_executable=""
	detected_startparameters=""

	if [ "${cfmcstartmode}" != "auto" ]; then
		return
	fi

	for script_name in startserver.sh start.sh run.sh; do
		if [ -f "${serverfiles}/${script_name}" ]; then
			chmod +x "${serverfiles}/${script_name}" 2> /dev/null
			detected_executable="./${script_name}"
			break
		fi
	done

	if [ -z "${detected_executable}" ]; then
		if [ -f "${serverfiles}/server.jar" ]; then
			jar_name="server.jar"
		elif [ -f "${serverfiles}/minecraft_server.jar" ]; then
			jar_name="minecraft_server.jar"
		else
			jar_name=$(find "${serverfiles}" -maxdepth 1 -type f -name "*.jar" ! -name "*installer*.jar" -printf "%f\n" 2> /dev/null | sort | head -n 1)
		fi

		if [ -n "${jar_name}" ]; then
			detected_preexecutable="java -Xmx${javaram}M -jar"
			detected_executable="./${jar_name}"
			detected_startparameters="nogui"
		fi
	fi

	fn_cfmc_persist_start_command
}

fn_update_dl() {
	local archive_filename="${remotebuildfilename}"

	if [ -n "${localpackpath}" ]; then
		cp -f "${localpackpath}" "${tmpdir}/${archive_filename}"
	else
		fn_fetch_file "${remotebuildurl}" "" "" "" "${tmpdir}" "${archive_filename}" "nochmodx" "norun" "force" "nohash"
	fi

	fn_cfmc_backup_preserve
	fn_dl_extract "${tmpdir}" "${archive_filename}" "${serverfiles}"
	fn_cfmc_restore_preserve
	echo "${remotebuildversion}" > "${serverfiles}/build.txt"
	fn_cfmc_detect_start_command
	fn_clear_tmp
}

fn_update_localbuild() {
	fn_print_dots "Checking local build: ${remotelocation}"
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
	fn_cfmc_validate_config
	if [ "${cfmcsource}" == "api" ]; then
		fn_cfmc_resolve_api_source
	else
		fn_cfmc_resolve_url_source
	fi
	fn_cfmc_build_remote_marker

	if [ "${firstcommandname}" != "INSTALL" ]; then
		fn_print_dots "Checking remote build: ${remotelocation}"
		if [ -z "${remotebuildversion}" ] || [ "${remotebuildversion}" == "null" ]; then
			fn_print_fail "Checking remote build: ${remotelocation}"
			fn_script_log_fail "Checking remote build"
			core_exit.sh
		else
			fn_print_ok "Checking remote build: ${remotelocation}"
			fn_script_log_pass "Checking remote build"
		fi
	else
		if [ -z "${remotebuildversion}" ] || [ "${remotebuildversion}" == "null" ]; then
			fn_print_failure "Unable to get remote build"
			fn_script_log_fail "Unable to get remote build"
			core_exit.sh
		fi
	fi
}

fn_update_compare() {
	fn_print_dots "Checking for update: ${remotelocation}"
	if [ "${localbuild}" != "${remotebuildversion}" ] || [ "${forceupdate}" == "1" ]; then
		date '+%s' > "${lockdir:?}/update.lock"
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		echo -en "\n"
		echo -e "Update available"
		echo -e "* Local build: ${red}${localbuild}${default}"
		echo -e "* Remote build: ${green}${remotebuildversion}${default}"
		if [ -f "${rootdir}/.dev-debug" ]; then
			echo -e "Remote build info"
			echo -e "* remotebuildfilename: ${remotebuildfilename}"
			echo -e "* remotebuildurl: ${remotebuildurl}"
			echo -e "* remotebuildversion: ${remotebuildversion}"
		fi
		echo -en "\n"
		fn_script_log_info "Update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuildversion}"
		fn_script_log_info "${localbuild} > ${remotebuildversion}"

		if [ "${commandname}" == "UPDATE" ]; then
			date +%s > "${lockdir}/last-updated.lock"
			unset updateonstart
			check_status.sh
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
		echo -en "\n"
		fn_script_log_info "No update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuildversion}"
		if [ -f "${rootdir}/.dev-debug" ]; then
			echo -e "Remote build info"
			echo -e "* remotebuildfilename: ${remotebuildfilename}"
			echo -e "* remotebuildurl: ${remotebuildurl}"
			echo -e "* remotebuildversion: ${remotebuildversion}"
		fi
	fi
}

remotelocation="curseforge.com"
resolvedfileid=""
resolvedsource=""
localpackpath=""
cfmc_preserve_dir=""
cfmc_preserve_paths=()

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
