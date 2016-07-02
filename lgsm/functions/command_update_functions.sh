#!/bin/bash
# LGSM command_update_functions.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Description: Deletes the functions dir to allow re-downloading of functions from GitHub.

function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"
check.sh
fn_print_dots "Updating functions"
fn_script_log_info "Updating functions"
sleep 1
echo -ne "\n"

# Removed legecy functions dir
if [ -n "${rootdir}" ]; then
	if [ -d "${rootdir}/functions/" ]; then
		rm -rfv "${rootdir}/functions/"
		exitcode=$?
	fi
fi

if [ -n "${functionsdir}" ]; then
	if [ -d "${functionsdir}" ]; then
		# Check curl exists and use available path
		curlpaths="$(command -v curl 2>/dev/null) $(which curl >/dev/null 2>&1) /usr/bin/curl /bin/curl /usr/sbin/curl /sbin/curl)"
		for curlcmd in ${curlpaths}
		do
			if [ -x "${curlcmd}" ]; then
				curlcmd=${curlcmd}
				break
			fi
		done
		cd "${functionsdir}"
		for functionfile in *
		do
			echo -ne "   checking ${functionfile}...\c"
			function_file_diff=$(diff "${functionsdir}/${functionfile}" <(${curlcmd} -s "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${functionfile}"))
			if [ "${function_file_diff}" != "" ]; then
				echo "files are different!!"
				${curlcmd} -s --fail "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${functionfile}"
				local exitcode=$?
				if [ "${exitcode}" != "0" ]; then
					echo -ne "   checking ${functionfile}...\c"
					fn_print_fail_eol_nl
					rm -rfv "${functionsdir}/${functionfile}"
					exitcode=2
				else
					echo -ne "   checking ${functionfile}...UPDATE"
					rm -rfv "${functionsdir}/${functionfile}"
					fn_update_function
				fi
			else
				echo -ne "   checking ${functionfile}...\c"
				fn_print_ok_eol_nl
			fi
		done
	fi
fi

if [ "${exitcode}" != "0" ]; then
	fn_print_fail "Updating functions"
	fn_script_log_fatal "Failure! Updating functions"
else
	fn_print_ok "Updating functions"
	fn_script_log_pass "Success! Updating functions"
	exitcode=0
fi
echo -ne "\n"
core_exit.sh