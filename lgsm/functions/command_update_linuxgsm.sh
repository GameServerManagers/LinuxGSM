#!/bin/bash
# LinuxGSM command_update_linuxgsm.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Deletes the functions dir to allow re-downloading of functions from GitHub.

commandname="UPDATE-LGSM"
commandaction="Updating LinuxGSM"
functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

check.sh

fn_print_dots ""
fn_script_log_info "Updating LinuxGSM"

fn_print_dots "Selecting repo"
fn_script_log_info "Selecting repo"
# Select remotereponame
curl -IsfL "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/linuxgsm.sh" 1>/dev/null
if [ $? != "0" ]; then
	curl -IsfL "https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/linuxgsm.sh" 1>/dev/null
	if [ $? != "0" ]; then
		fn_print_fail_nl "Selecting repo: Unable to to access GitHub or Bitbucket repositories"
		fn_script_log_fatal "Selecting repo: Unable to to access GitHub or Bitbucket repositories"
		core_exit.sh
	else
		remotereponame="Bitbucket"
		fn_print_ok_nl "Selecting repo: ${remotereponame}"
	fi
else
	remotereponame="GitHub"
	fn_print_ok_nl "Selecting repo: ${remotereponame}"
fi

# Check linuxsm.sh
echo -en "checking ${remotereponame} linuxgsm.sh...\c"
if [ "${remotereponame}" == "GitHub" ]; then
	curl -IsfL "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/linuxgsm.sh" 1>/dev/null
else
	curl -IsfL "https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/linuxgsm.sh" 1>/dev/null
fi
if [ $? != "0" ]; then
	fn_print_fail_eol_nl
	fn_script_log_fatal "Checking ${remotereponame} linuxgsm.sh"
	fn_script_log_fatal "Curl returned error: $?"
	core_exit.sh
fi

if [ "${remotereponame}" == "GitHub" ]; then
	tmp_script_diff=$(diff "${tmpdir}/linuxgsm.sh" <(curl -s "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/linuxgsm.sh"))
else
	tmp_script_diff=$(diff "${tmpdir}/linuxgsm.sh" <(curl -s "https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/linuxgsm.sh"))
fi

if [ "${tmp_script_diff}" != "" ]; then
	fn_print_update_eol_nl
	fn_script_log_update "Checking ${remotereponame} linuxgsm.sh"
	rm -f "${tmpdir:?}/linuxgsm.sh"
	fn_fetch_file_github "" "linuxgsm.sh" "${tmpdir}" "nochmodx" "norun" "noforcedl" "nomd5"
else
	fn_print_ok_eol_nl
	fn_script_log_pass "Checking ${remotereponame} linuxgsm.sh"
fi

# Check gameserver.sh
# Compare gameserver.sh against linuxgsm.sh in the tmp dir.
# Ignoring server specific vars.
echo -en "checking ${selfname}...\c"
fn_script_log_info "Checking ${selfname}"
script_diff=$(diff <(sed '\/shortname/d;\/gameservername/d;\/gamename/d;\/githubuser/d;\/githubrepo/d;\/githubbranch/d' "${tmpdir}/linuxgsm.sh") <(sed '\/shortname/d;\/gameservername/d;\/gamename/d;\/githubuser/d;\/githubrepo/d;\/githubbranch/d' "${rootdir}/${selfname}"))
if [ "${script_diff}" != "" ]; then
	fn_print_update_eol_nl
	fn_script_log_update "Checking ${selfname}"
	echo -en "backup ${selfname}...\c"
	fn_script_log_info "Backup ${selfname}"
	if [ ! -d "${backupdir}/script" ]; then
		mkdir -p "${backupdir}/script"
	fi
	cp "${rootdir}/${selfname}" "${backupdir}/script/${selfname}-$(date +"%m_%d_%Y_%M").bak"
	if [ $? != 0 ]; then
		fn_print_fail_eol_nl
		fn_script_log_fatal "Backup ${selfname}"
		core_exit.sh
	else
		fn_print_ok_eol_nl
		fn_script_log_pass "Backup ${selfname}"
		echo -e "backup location ${backupdir}/script/${selfname}-$(date +"%m_%d_%Y_%M").bak"
		fn_script_log_pass "Backup location ${backupdir}/script/${selfname}-$(date +"%m_%d_%Y_%M").bak"
	fi

	echo -en "copying ${selfname}...\c"
	fn_script_log_info "copying ${selfname}"
	cp "${tmpdir}/linuxgsm.sh" "${rootdir}/${selfname}"
	sed -i "s+shortname=\"core\"+shortname=\"${shortname}\"+g" "${rootdir}/${selfname}"
	sed -i "s+gameservername=\"core\"+gameservername=\"${gameservername}\"+g" "${rootdir}/${selfname}"
	sed -i "s+gamename=\"core\"+gamename=\"${gamename}\"+g" "${rootdir}/${selfname}"
	sed -i "s+githubuser=\"GameServerManagers\"+githubuser=\"${githubuser}\"+g" "${rootdir}/${selfname}"
	sed -i "s+githubrepo=\"LinuxGSM\"+githubrepo=\"${githubrepo}\"+g" "${rootdir}/${selfname}"
	sed -i "s+githubbranch=\"master\"+githubbranch=\"${githubbranch}\"+g" "${rootdir}/${selfname}"

	if [ $? != "0" ]; then
		fn_print_fail_eol_nl
		fn_script_log_fatal "copying ${selfname}"
		core_exit.sh
	else
		fn_print_ok_eol_nl
		fn_script_log_pass "copying ${selfname}"
	fi
else
	fn_print_ok_eol_nl
	fn_script_log_info "Checking ${selfname}"
fi

# Check _default.cfg.
echo -en "checking ${remotereponame} config _default.cfg...\c"
fn_script_log_info "Checking ${remotereponame} config _default.cfg"
if [ "${remotereponame}" == "GitHub" ]; then
	curl -IsfL "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/config-default/config-lgsm/${gameservername}/_default.cfg" 1>/dev/null
else
	curl -IsfL "https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/lgsm/config-default/config-lgsm/${gameservername}/_default.cfg" 1>/dev/null
fi
if [ $? != "0" ]; then
	fn_print_fail_eol_nl
	fn_script_log_fatal "Checking ${remotereponame} config _default.cfg"
	fn_script_log_fatal "Curl returned error: $?"
	core_exit.sh
fi

if [ "${remotereponame}" == "GitHub" ]; then
	config_file_diff=$(diff "${configdirdefault}/config-lgsm/${gameservername}/_default.cfg" <(curl -s "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/config-default/config-lgsm/${gameservername}/_default.cfg"))
else
	config_file_diff=$(diff "${configdirdefault}/config-lgsm/${gameservername}/_default.cfg" <(curl -s "https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/lgsm/config-default/config-lgsm/${gameservername}/_default.cfg"))
fi

if [ "${config_file_diff}" != "" ]; then
	fn_print_update_eol_nl
	fn_script_log_update "Checking ${remotereponame} config _default.cfg"
	rm -f "${configdirdefault:?}/config-lgsm/${gameservername:?}/_default.cfg"
	fn_fetch_file_github "lgsm/config-default/config-lgsm/${gameservername}" "_default.cfg" "${configdirdefault}/config-lgsm/${gameservername}" "nochmodx" "norun" "noforce" "nomd5"
	alert="config"
	alert.sh
else
	fn_print_ok_eol_nl
	fn_script_log_pass "Checking ${remotereponame} config _default.cfg"
fi

# Check and update modules.
if [ -n "${functionsdir}" ]; then
	if [ -d "${functionsdir}" ]; then
		cd "${functionsdir}" || exit
		for functionfile in *; do
			# check if module exists in the repo and remove if missing.
			# commonly used if module names change.
			echo -en "checking ${remotereponame} module ${functionfile}...\c"
			github_file_url_dir="lgsm/functions"
			if [ "${remotereponame}" == "GitHub" ]; then
				curl -IsfL "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${functionfile}" 1>/dev/null
			else
				curl -IsfL "https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/${github_file_url_dir}/${functionfile}" 1>/dev/null
			fi
			if [ $? != 0 ]; then
				fn_print_error_eol_nl
				fn_script_log_error "Checking ${remotereponame} module ${functionfile}"
				echo -en "removing module ${functionfile}...\c"
				if ! rm -f "${functionfile:?}"; then
					fn_print_fail_eol_nl
					fn_script_log_fatal "Removing module ${functionfile}"
					core_exit.sh
				else
					fn_print_ok_eol_nl
					fn_script_log_pass "Removing module ${functionfile}"
				fi
			else
				# compare file
				if [ "${remotereponame}" == "GitHub" ]; then
					function_file_diff=$(diff "${functionsdir}/${functionfile}" <(curl -s "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${functionfile}"))
				else
					function_file_diff=$(diff "${functionsdir}/${functionfile}" <(curl -s "https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/${github_file_url_dir}/${functionfile}"))
				fi

				# results
				if [ "${function_file_diff}" != "" ]; then
					fn_print_update_eol_nl
					fn_script_log_update "Checking ${remotereponame} module ${functionfile}"
					rm -rf "${functionsdir:?}/${functionfile}"
					fn_update_function
				else
					fn_print_ok_eol_nl
					fn_script_log_pass "Checking ${remotereponame} module ${functionfile}"
				fi
			fi
		done
	fi
fi

fn_print_ok_nl "Updating functions"
fn_script_log_pass "Updating functions"

core_exit.sh
