#!/bin/bash
# LGSM command_update_functions.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Deletes the functions dir to allow re-downloading of functions from GitHub.

local commandaction="Update LGSM"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_print_dots "Updating functions"
sleep 1
check.sh
fn_script_log_info "Updating functions"
echo -ne "\n"

# Removed legacy functions dir
if [ -n "${rootdir}" ]; then
	if [ -d "${rootdir}/functions/" ]; then
		rm -rfv "${rootdir}/functions/"
		exitcode=$?
	fi
fi

if [ -n "${functionsdir}" ]; then
	if [ -d "${functionsdir}" ]; then
		cd "${functionsdir}"
		for functionfile in *
		do
			# Check if curl exists and use available path
			curlpaths="$(command -v curl 2>/dev/null) $(which curl >/dev/null 2>&1) /usr/bin/curl /bin/curl /usr/sbin/curl /sbin/curl)"
			for curlcmd in ${curlpaths}
			do
				if [ -x "${curlcmd}" ]; then
					curlcmd=${curlcmd}
					break
				fi
			done

			echo -ne "    checking ${functionfile}...\c"
			function_file_diff=$(diff "${functionsdir}/${functionfile}" <(${curlcmd} -s "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${functionfile}"))
			if [ "${function_file_diff}" != "" ]; then
				fn_print_update_eol_nl
				fn_script_log_info "checking ${functionfile}: UPDATE"
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