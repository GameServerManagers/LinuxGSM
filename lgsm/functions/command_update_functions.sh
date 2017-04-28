#!/bin/bash
# LinuxGSM command_update_functions.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Deletes the functions dir to allow re-downloading of functions from GitHub.

local commandname="UPDATE LinuxGSM"
local commandaction="Update LinuxGSM"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_print_dots "Updating LinuxGSM"
sleep 1
check.sh
fn_script_log_info "Updating LinuxGSM"
echo -ne "\n"

# Check and update _default.cfg
echo -ne "    checking config _default.cfg...\c"
config_file_diff=$(diff "${configdirdefault}/config-lgsm/${servername}/_default.cfg" <(${curlpath} -s "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/config-default/config-lgsm/${servername}/_default.cfg"))
if [ "${config_file_diff}" != "" ]; then
	fn_print_update_eol_nl
	fn_script_log_info "checking config _default.cfg: UPDATE"
	rm -f "${configdirdefault}/config-lgsm/${servername}/_default.cfg"
	fn_fetch_config "lgsm/config-default/config-lgsm/${servername}" "_default.cfg" "${configdirdefault}/config-lgsm/${servername}" "_default.cfg" "noexecutecmd" "norun" "noforce" "nomd5"
else
	fn_print_ok_eol_nl
fi

echo -ne "    checking linuxgsm.sh...\c"
config_script_diff=$(diff "${tmpdir}/linuxgsm.sh" <(${curlpath} -s "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/linuxgsm.sh"))
if [ "${config_file_diff}" != "" ]; then
	fn_print_update_eol_nl
	fn_script_log_info "checking ${selfname}: UPDATE"
	rm -f "${tmpdir}/linuxgsm.sh"
	fn_fetch_file_github "" "linuxgsm.sh" "${tmpdir}" "linuxgsm.sh" "noexecutecmd" "norun" "noforce" "nomd5"
else
	fn_print_ok_eol_nl
fi

# Check and update functions
if [ -n "${functionsdir}" ]; then
	if [ -d "${functionsdir}" ]; then
		cd "${functionsdir}"
		for functionfile in *
		do
			echo -ne "    checking function ${functionfile}...\c"
			function_file_diff=$(diff "${functionsdir}/${functionfile}" <(${curlpath} -s "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${functionfile}"))
			if [ "${function_file_diff}" != "" ]; then
				fn_print_update_eol_nl
				fn_script_log_info "checking function ${functionfile}: UPDATE"
				rm -rf "${functionsdir}/${functionfile}"
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
echo -ne "\n"
core_exit.sh