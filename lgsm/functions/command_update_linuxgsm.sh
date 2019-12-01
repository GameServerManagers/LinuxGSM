#!/bin/bash
# LinuxGSM command_update_linuxgsm.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Deletes the functions dir to allow re-downloading of functions from GitHub.

local commandname="UPDATE LINUXGSM"
local commandaction="Update LinuxGSM"
local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

fn_print_dots "Updating LinuxGSM"
check.sh
fn_script_log_info "Updating LinuxGSM"
echo -en "\n"

if [ -z "${legacymode}" ]; then
	# Check and update _default.cfg.
	echo -en "    checking config _default.cfg...\c"
	config_file_diff=$(diff "${configdirdefault}/config-lgsm/${gameservername}/_default.cfg" <(curl -s "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/config-default/config-lgsm/${gameservername}/_default.cfg"))
	if [ "${config_file_diff}" != "" ]; then
		fn_print_update_eol_nl
		fn_script_log_info "checking config _default.cfg: UPDATE"
		rm -f "${configdirdefault}/config-lgsm/${gameservername}/_default.cfg"
		fn_fetch_config "lgsm/config-default/config-lgsm/${gameservername}" "_default.cfg" "${configdirdefault}/config-lgsm/${gameservername}" "_default.cfg" "nochmodx" "norun" "noforce" "nomd5"
		alert="config"
		alert.sh
	else
		fn_print_ok_eol_nl
		fn_script_log_info "checking config _default.cfg: OK"
	fi

	echo -en "    checking linuxgsm.sh...\c"
	tmp_script_diff=$(diff "${tmpdir}/linuxgsm.sh" <(curl -s "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/linuxgsm.sh"))
	if [ "${tmp_script_diff}" != "" ]; then
		fn_print_update_eol_nl
		fn_script_log_info "checking linuxgsm.sh: UPDATE"
		rm -f "${tmpdir}/linuxgsm.sh"
		fn_fetch_file_github "" "linuxgsm.sh" "${tmpdir}" "nochmodx" "norun" "noforcedl" "nomd5"
		# Compare selfname against linuxgsm.sh in the tmp dir. Ignoring server specific vars.
	else
		fn_script_log_info "checking linuxgsm.sh: OK"
		fn_print_ok_eol_nl
	fi
	echo -en "    checking ${selfname}...\c"
	script_diff=$(diff <(sed '\/shortname/d;\/gameservername/d;\/gamename/d;\/githubuser/d;\/githubrepo/d;\/githubbranch/d' "${tmpdir}/linuxgsm.sh") <(sed '\/shortname/d;\/gameservername/d;\/gamename/d;\/githubuser/d;\/githubrepo/d;\/githubbranch/d' "${rootdir}/${selfname}"))
	if [ "${script_diff}" != "" ]; then
		fn_print_update_eol_nl
		echo -en "    backup ${selfname}...\c"
		mkdir -p "${backupdir}/script/"
		cp "${rootdir}/${selfname}" "${backupdir}/script/${selfname}-$(date +"%m_%d_%Y_%M").bak"
		if [ $? -ne 0 ]; then
			fn_print_fail_eol_nl
			core_exit.sh
		else
			fn_print_ok_eol_nl
			echo -e "	Backup: ${backupdir}/script/${selfname}-$(date +"%m_%d_%Y_%M").bak"
		fi
		echo -en "    fetching ${selfname}...\c"
		cp "${tmpdir}/linuxgsm.sh" "${rootdir}/${selfname}"
		sed -i "s/shortname=\"core\"/shortname=\"${shortname}\"/g" "${rootdir}/${selfname}"
		sed -i "s/gameservername=\"core\"/gameservername=\"${gameservername}\"/g" "${rootdir}/${selfname}"
		sed -i "s/gamename=\"core\"/gamename=\"${gamename}\"/g" "${rootdir}/${selfname}"
		exitcode=$?
		if [ "${exitcode}" != "0" ]; then
			fn_print_fail_eol_nl
			core_exit.sh
		else
			fn_print_ok_eol_nl
		fi
	else
		fn_print_ok_eol_nl
	fi
fi

# Check and update functions.
if [ -n "${functionsdir}" ]; then
	if [ -d "${functionsdir}" ]; then
		cd "${functionsdir}" || exit
		for functionfile in *
		do
			echo -en "    checking function ${functionfile}...\c"
			github_file_url_dir="lgsm/functions"
			get_function_file=$(curl --fail -s "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${functionfile}")
			exitcode=$?
			function_file_diff=$(diff "${functionsdir}/${functionfile}" <(curl --fail -s "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${functionfile}"))
			if [ ${exitcode} -ne 0 ]; then
				fn_print_fail_eol_nl
				echo -en "    removing unknown function ${functionfile}...\c"
				fn_script_log_fatal "removing unknown function ${functionfile}"
				if ! rm -f "${functionfile}"; then
					fn_print_fail_eol_nl
					core_exit.sh
				else
					fn_print_ok_eol_nl
				fi
			elif [ "${function_file_diff}" != "" ]; then
				fn_print_update_eol_nl
				fn_script_log_info "checking function ${functionfile}: UPDATE"
				rm -rf "${functionsdir:?}/${functionfile}"
				fn_update_function
			else
				fn_print_ok_eol_nl
			fi
		done
	fi
fi

if [ "${exitcode}" != "0" ]&&[ -n "${exitcode}" ]; then
	fn_print_fail "Updating functions"
	fn_script_log_fatal "Updating functions"
else
	fn_print_ok "Updating functions"
	fn_script_log_pass "Updating functions"
fi

core_exit.sh
