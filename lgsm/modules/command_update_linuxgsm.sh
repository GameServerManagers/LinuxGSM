#!/bin/bash
# LinuxGSM command_update_linuxgsm.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Deletes the modules dir to allow re-downloading of modules from GitHub.

commandname="UPDATE-LGSM"
commandaction="Updating LinuxGSM"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

fn_print_dots ""
check.sh
info_distro.sh
info_game.sh

# Prevent github from using a cached version of the file if dev-debug is enabled.
if [ -f "${rootdir}/.dev-debug" ]; then
	nocache="-H \"Cache-Control: no-cache\" -H \"Pragma: no-cache\""
fi

fn_script_log_info "Updating LinuxGSM"

fn_print_dots "Selecting repo"
fn_script_log_info "Selecting repo"
# Select remotereponame

curl ${nocache} --connect-timeout 3 -IsfL "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/linuxgsm.sh" 1> /dev/null
exitcode=$?
if [ "${exitcode}" -ne "0" ]; then
	curl ${nocache} --connect-timeout 3 -IsfL "https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/linuxgsm.sh" 1> /dev/null
	exitcode=$?
	if [ "${exitcode}" -ne "0" ]; then
		fn_print_fail_nl "Selecting repo: Unable to to access GitHub or Bitbucket repositories"
		fn_script_log_fail "Selecting repo: Unable to to access GitHub or Bitbucket repositories"
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
echo -en "checking ${remotereponame} script [ ${italic}linuxgsm.sh${default} ]\c"
if [ "${remotereponame}" == "GitHub" ]; then
	curl ${nocache} --connect-timeout 3 -IsfL "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/linuxgsm.sh" 1> /dev/null
else
	curl ${nocache} --connect-timeout 3 -IsfL "https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/linuxgsm.sh" 1> /dev/null
fi
exitcode=$?
if [ "${exitcode}" -ne 0 ]; then
	fn_print_fail_eol_nl
	fn_script_log_fail "Checking ${remotereponame} linuxgsm.sh"
	fn_script_log_fail "Curl returned error: ${exitcode}"
	core_exit.sh
fi

if [ "${remotereponame}" == "GitHub" ]; then
	tmp_script_diff=$(diff "${tmpdir}/linuxgsm.sh" <(curl ${nocache} --connect-timeout 3 -s "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/linuxgsm.sh"))
else
	tmp_script_diff=$(diff "${tmpdir}/linuxgsm.sh" <(curl ${nocache} --connect-timeout 3 -s "https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/linuxgsm.sh"))
fi

if [ "${tmp_script_diff}" != "" ]; then
	fn_print_update_eol_nl
	fn_script_log "Checking ${remotereponame} script linuxgsm.sh"
	rm -f "${tmpdir:?}/linuxgsm.sh"
	fn_fetch_file_github "" "linuxgsm.sh" "${tmpdir}" "nochmodx" "norun" "noforcedl" "nohash"
else
	fn_print_skip_eol_nl
	fn_script_log_pass "Checking ${remotereponame} script linuxgsm.sh"
fi

# Check gameserver.sh
# Compare gameserver.sh against linuxgsm.sh in the tmp dir.
# Ignoring server specific vars.
echo -en "checking script [ ${italic}${selfname}${default} ]\c"
fn_script_log_info "Checking ${selfname}"
script_diff=$(diff <(sed '\/shortname/d;\/gameservername/d;\/gamename/d;\/githubuser/d;\/githubrepo/d;\/githubbranch/d' "${tmpdir}/linuxgsm.sh") <(sed '\/shortname/d;\/gameservername/d;\/gamename/d;\/githubuser/d;\/githubrepo/d;\/githubbranch/d' "${rootdir}/${selfname}"))
if [ "${script_diff}" != "" ]; then
	fn_print_update_eol_nl
	fn_script_log "Checking script ${selfname}"
	echo -en "backup ${selfname}\c"
	fn_script_log_info "Backup script ${selfname}"
	if [ ! -d "${backupdir}/script" ]; then
		mkdir -p "${backupdir}/script"
	fi
	cp "${rootdir}/${selfname}" "${backupdir}/script/${selfname}-$(date +"%m_%d_%Y_%M").bak"
	exitcode=$?
	if [ "${exitcode}" -ne 0 ]; then
		fn_print_fail_eol_nl
		fn_script_log_fail "Backup ${selfname}"
		core_exit.sh
	else
		fn_print_ok_eol_nl
		fn_script_log_pass "Backup script${selfname}"
		echo -e "backup location [ ${backupdir}/script/${selfname}-$(date +"%m_%d_%Y_%M").bak ]"
		fn_script_log_pass "Backup location ${backupdir}/script/${selfname}-$(date +"%m_%d_%Y_%M").bak"
	fi

	echo -en "copying ${selfname}"
	fn_script_log_info "Copying ${selfname}"
	cp "${tmpdir}/linuxgsm.sh" "${rootdir}/${selfname}"
	sed -i "s+shortname=\"core\"+shortname=\"${shortname}\"+g" "${rootdir}/${selfname}"
	sed -i "s+gameservername=\"core\"+gameservername=\"${gameservername}\"+g" "${rootdir}/${selfname}"
	sed -i "s+gamename=\"core\"+gamename=\"${gamename}\"+g" "${rootdir}/${selfname}"
	sed -i "s+githubuser=\"GameServerManagers\"+githubuser=\"${githubuser}\"+g" "${rootdir}/${selfname}"
	sed -i "s+githubrepo=\"LinuxGSM\"+githubrepo=\"${githubrepo}\"+g" "${rootdir}/${selfname}"
	sed -i "s+githubbranch=\"master\"+githubbranch=\"${githubbranch}\"+g" "${rootdir}/${selfname}"

	exitcode=$?
	if [ "${exitcode}" -ne 0 ]; then
		fn_print_fail_eol_nl
		fn_script_log_fail "copying ${selfname}"
		core_exit.sh
	else
		fn_print_ok_eol_nl
		fn_script_log_pass "copying ${selfname}"
	fi
else
	fn_print_skip_eol_nl
	fn_script_log_info "Checking ${selfname}"
fi

# Check _default.cfg.
echo -en "checking ${remotereponame} config [ ${italic}_default.cfg${default} ]\c"
fn_script_log_info "Checking ${remotereponame} config _default.cfg"
if [ "${remotereponame}" == "GitHub" ]; then
	curl ${nocache} --connect-timeout 3 -IsfL "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/config-default/config-lgsm/${gameservername}/_default.cfg" 1> /dev/null
else
	curl ${nocache} --connect-timeout 3 -IsfL "https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/lgsm/config-default/config-lgsm/${gameservername}/_default.cfg" 1> /dev/null
fi
exitcode=$?
if [ "${exitcode}" -ne 0 ]; then
	fn_print_fail_eol_nl
	fn_script_log_fail "Checking ${remotereponame} config _default.cfg"
	fn_script_log_fail "Curl returned error: ${exitcode}"
	core_exit.sh
fi

if [ "${remotereponame}" == "GitHub" ]; then
	config_file_diff=$(diff "${configdirdefault}/config-lgsm/${gameservername}/_default.cfg" <(curl ${nocache} --connect-timeout 3 -s "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/config-default/config-lgsm/${gameservername}/_default.cfg"))
else
	config_file_diff=$(diff "${configdirdefault}/config-lgsm/${gameservername}/_default.cfg" <(curl ${nocache} --connect-timeout 3 -s "https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/lgsm/config-default/config-lgsm/${gameservername}/_default.cfg"))
fi

if [ "${config_file_diff}" != "" ]; then
	fn_print_update_eol_nl
	fn_script_log "Checking ${remotereponame} config _default.cfg"
	rm -f "${configdirdefault:?}/config-lgsm/${gameservername:?}/_default.cfg"
	fn_fetch_file_github "lgsm/config-default/config-lgsm/${gameservername}" "_default.cfg" "${configdirdefault}/config-lgsm/${gameservername}" "nochmodx" "norun" "noforce" "nohash"
	alert="config"
	alert.sh
else
	fn_print_skip_eol_nl
	fn_script_log_pass "Checking ${remotereponame} config _default.cfg"
fi

# Check distro csv. ${datadir}/${distroid}-${distroversioncsv}.csv
if [ -f "${datadir}/${distroid}-${distroversioncsv}.csv" ]; then
	echo -en "checking ${remotereponame} config [ ${italic}${distroid}-${distroversioncsv}.csv${default} ]\c"
	fn_script_log_info "Checking ${remotereponame} ${distroid}-${distroversioncsv}.csv"
	if [ "${remotereponame}" == "GitHub" ]; then
		curl ${nocache} --connect-timeout 3 -IsfL "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/${distroid}-${distroversioncsv}.csv" 1> /dev/null
	else
		curl ${nocache} --connect-timeout 3 -IsfL "https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/lgsm/data/${distroid}-${distroversioncsv}.csv" 1> /dev/null
	fi
	exitcode=$?
	if [ "${exitcode}" -ne 0 ]; then
		fn_print_fail_eol_nl
		fn_script_log_fail "Checking ${remotereponame} ${distroid}-${distroversioncsv}.csv"
		fn_script_log_fail "Curl returned error: ${exitcode}"
		core_exit.sh
	fi

	if [ "${remotereponame}" == "GitHub" ]; then
		config_file_diff=$(diff "${datadir}/${distroid}-${distroversioncsv}.csv" <(curl ${nocache} --connect-timeout 3 -s "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/${distroid}-${distroversioncsv}.csv"))
	else
		config_file_diff=$(diff "${datadir}/${distroid}-${distroversioncsv}.csv" <(curl ${nocache} --connect-timeout 3 -s "https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/lgsm/data/${distroid}-${distroversioncsv}.csv"))
	fi

	if [ "${config_file_diff}" != "" ]; then
		fn_print_update_eol_nl
		fn_script_log "Checking ${remotereponame} ${distroid}-${distroversioncsv}.csv"
		rm -f "${datadir:?}/${distroid}-${distroversioncsv}.csv"
		fn_fetch_file_github "${datadir}" "${distroid}-${distroversioncsv}.csv" "${datadir}" "nochmodx" "norun" "noforce" "nohash"
	else
		fn_print_skip_eol_nl
		fn_script_log_pass "Checking ${remotereponame} ${distroid}-${distroversioncsv}.csv"
	fi
fi
# Check and update modules.
if [ -n "${modulesdir}" ]; then
	if [ -d "${modulesdir}" ]; then
		(
			cd "${modulesdir}" || exit
			for modulefile in *; do
				# check if module exists in the repo and remove if missing.
				# commonly used if module names change.
				echo -en "checking ${remotereponame} module [ ${italic}${modulefile}${default} ]\c"
				github_file_url_dir="lgsm/modules"
				if [ "${remotereponame}" == "GitHub" ]; then
					curl ${nocache} --connect-timeout 3 -IsfL "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${modulefile}" 1> /dev/null
				else
					curl ${nocache} --connect-timeout 3 -IsfL "https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/${github_file_url_dir}/${modulefile}" 1> /dev/null
				fi
				exitcode=$?
				if [ "${exitcode}" -ne 0 ]; then
					fn_print_error_eol_nl
					fn_script_log_error "Checking ${remotereponame} module ${modulefile}"
					echo -en "removing module ${modulefile}...\c"
					if ! rm -f "${modulefile:?}"; then
						fn_print_fail_eol_nl
						fn_script_log_fail "Removing module ${modulefile}"
						core_exit.sh
					else
						fn_print_ok_eol_nl
						fn_script_log_pass "Removing module ${modulefile}"
					fi
				else
					# compare file
					if [ "${remotereponame}" == "GitHub" ]; then
						module_file_diff=$(diff "${modulesdir}/${modulefile}" <(curl ${nocache} --connect-timeout 3 -s "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${modulefile}"))
					else
						module_file_diff=$(diff "${modulesdir}/${modulefile}" <(curl ${nocache} --connect-timeout 3 -s "https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/${github_file_url_dir}/${modulefile}"))
					fi

					# results
					if [ "${module_file_diff}" != "" ]; then
						fn_print_update_eol_nl
						fn_script_log "Checking ${remotereponame} module ${modulefile}"
						rm -rf "${modulesdir:?}/${modulefile}"
						fn_update_module
					else
						fn_print_skip_eol_nl
						fn_script_log_pass "Checking ${remotereponame} module ${modulefile}"
					fi
				fi
			done
		)
	fi
fi

fn_print_ok_nl "Updating modules"
fn_script_log_pass "Updating modules"

core_exit.sh
